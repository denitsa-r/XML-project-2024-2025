<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" indent="yes" doctype-public="-//W3C//DTD HTML 4.01//EN" doctype-system="http://www.w3.org/TR/html4/strict.dtd" />

    <xsl:param name="loadDocument">true</xsl:param>

    <xsl:param name="showAll">true</xsl:param>
    <xsl:param name="showId"></xsl:param>

    <xsl:param name="sortOn"></xsl:param>
    <xsl:param name="sortOrder">ascending</xsl:param>
    <xsl:param name="sortType">text</xsl:param>

    <xsl:param name="filterOn"></xsl:param>
    <xsl:param name="filterValue"></xsl:param>

    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$loadDocument = 'true'">
                <xsl:call-template name="loadDocument" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="loadContent" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="loadDocument">
        <html lang="en">
            <head>
                <meta charset="utf-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1" />
                <title><xsl:text>Movie catalogue</xsl:text></title>
                <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN" crossorigin="anonymous"/>
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" />
                <link rel="stylesheet" href="./dist/css/main.min.css" />
            </head>
            <body>
                <div id="content" class="p-5 d-flex flex-column justify-content-center">
                    <xsl:call-template name="loadContent" />
                </div>
            </body>

            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL" crossorigin="anonymous"/>

            <script defer="true">
                let imageUrlsMap = [
                <xsl:for-each select="//*[boolean(@source)]">
                    <xsl:text>["</xsl:text>
                    <xsl:value-of select="@source"/>
                    <xsl:text>" , "</xsl:text>
                    <xsl:value-of select="unparsed-entity-uri(@source)"/>
                    <xsl:text>"], </xsl:text>
                </xsl:for-each>
                ];
                const updateImageSource = () => {
                    imageUrlsMap.forEach(([original, updated]) => {
                        document.querySelectorAll(`.cover[style*="background-image:url('${original}')"]`)
                            .forEach(el => {
                                el.style.backgroundImage = `url('${updated}')`;
                            });
                    });
                };

                let trailerUrlsMap = [
                    <xsl:for-each select="//*[boolean(@source)]">
                        <xsl:text>["</xsl:text>
                        <xsl:value-of select="@source"/>
                        <xsl:text>" , "</xsl:text>
                        <xsl:value-of select="unparsed-entity-uri(@source)"/>
                        <xsl:text>"], </xsl:text>
                    </xsl:for-each>
                ];

                const updateTrailerSource = () => {
                    trailerUrlsMap.forEach(([original, updated]) => {
                        document.querySelectorAll(`iframe[src*='${original}']`)
                            .forEach(el => {
                                el.src = updated;
                            });
                    });
                };

                let state = {
                    loadDocument: "false",
                    showAll: "true",
                    showId: "",
                    sortOn: "",
                    sortOrder: "ascending",
                    sortType: "text",
                    filterOn: "",
                    filterValue: ""
                };

                const xmlDocPath = "movie_catalog.xml";
                const xslDocPath = "movie_catalog.xsl";

                let xsltProcessor;
                let xmlDoc;

                const initialize = async () => {
                    try {
                        const parser = new DOMParser();
                        xsltProcessor = new XSLTProcessor();

                        const xslResponse = await fetch(xslDocPath);
                        const xslText = await xslResponse.text();
                        const xslStylesheet = parser.parseFromString(xslText, "application/xml");
                        xsltProcessor.importStylesheet(xslStylesheet);

                        const xmlResponse = await fetch(xmlDocPath);
                        const xmlText = await xmlResponse.text();
                        xmlDoc = parser.parseFromString(xmlText, "application/xml");
                    } catch(e) {
                        document.getElementById("sortOptionsMenu").classList.remove("d-flex");
                        document.getElementById("sortOptionsMenu").classList.add("d-none");
                        for(const el of document.getElementsByClassName("showMoreBut")) el.classList.add("d-none");
                    }

                    updateImageSource();
                    updateTrailerSource();
                };
                
                const updateContent = () => {
                    xsltProcessor.clearParameters();

                    for (const [key, value] of Object.entries(state)) {
                        xsltProcessor.setParameter(null, key, value);
                    }

                    let fragment = xsltProcessor.transformToFragment(xmlDoc,document);

                    document.getElementById("content").textContent = "";
                    document.getElementById("content").appendChild(fragment);

                    updateImageSource();
                    updateTrailerSource();
                };

                const orderBy = (sortOn, sortOrder, sortType) => {
                    console.log(sortOn);
                    state.sortOn = sortOn;
                    state.sortOrder = sortOrder;
                    state.sortType = sortType;
                    console.log({ sortOn, sortOrder, sortType });

                    updateContent();
                };

                const filterBy = (filterOn, filterValue) => {
                    state.filterOn = filterOn;
                    state.filterValue = filterValue;
                    console.log({ filterOn, filterValue });

                    updateContent();
                };

                const showHotelInfo = (showId) => {
                    state.showAll = "false";
                    state.showId = showId;

                    updateContent();
                };

                const showAllHotels = () => {
                    state.showAll = "true";
                    state.showId = "";

                    updateContent();
                };

                initialize();

            </script>
        </html>
    </xsl:template>

    <xsl:template name="loadContent">
        <xsl:choose>
            <xsl:when test="$showAll = 'true'">
            <h1 class="heading-xl mb-5">Movies catalogue</h1>
                <div id="sortOptionsMenu" class="d-flex justify-content-around mb-5">
                    <div class="dropdown">
                        <button class="btn  dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                            Choose Genre
                        </button>
                        <ul class="dropdown-menu">
                            <li>
                                <button onclick="filterBy('','')" class="dropdown-item">All genres</button>
                            </li>
                            <xsl:for-each select="movie_catalog/genres/genre">
                                <li>
                                    <button onclick="filterBy('genre','{@id}')" class="dropdown-item">
                                        <xsl:call-template name="genreShow">
                                            <xsl:with-param name="genreId" select="@id" />
                                        </xsl:call-template>
                                    </button>
                                </li>
                            </xsl:for-each>

                        </ul>
                    </div>

                    <div class="dropdown">
                        <button class="btn  dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                            Choose Series
                        </button>
                        <ul class="dropdown-menu">
                            <li>
                                <button onclick="filterBy('','')" class="dropdown-item">All movies</button>
                            </li>
                            <xsl:for-each select="movie_catalog/movie-series/series">
                                <li>
                                    <button onclick="filterBy('series','{@id}')" class="dropdown-item">
                                        <xsl:value-of select="." />
                                    </button>
                                </li>
                            </xsl:for-each>

                        </ul>
                    </div>

                    <div class="dropdown">
                        <button class="btn  dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                            Order by
                        </button>
                        <ul class="dropdown-menu">
                            <li>
                                <button onclick="orderBy('','ascending','text')" class="dropdown-item">Default</button>
                            </li>
                            <li>
                                <button onclick="orderBy('year','ascending','text')" class="dropdown-item">Year ↑</button>
                            </li>
                            <li>
                                <button onclick="orderBy('year','descending','text')" class="dropdown-item">Year ↓</button>
                            </li>
                            <li>
                                <button onclick="orderBy('rating','ascending','text')" class="dropdown-item">Rating ↑</button>
                            </li>
                            <li>
                                <button onclick="orderBy('rating','descending','text')" class="dropdown-item">Rating ↓</button>
                            </li>
                            <li>
                                <button onclick="orderBy('title','ascending','text')" class="dropdown-item">A-Z</button>
                            </li>
                            <li>
                                <button onclick="orderBy('title','descending','text')" class="dropdown-item">Z-A</button>
                            </li>
                        </ul>
                    </div>

                </div>
                <xsl:call-template name="movie-list" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="single-movie" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="movie-list">
        <div class="movie-list">
            <xsl:for-each select="/movie_catalog/movies/movie">
            <!-- Сортиране по един критерий според параметъра sortOn -->
            <xsl:sort select="details/*[name() = $sortOn]" data-type="{$sortType}" order="{$sortOrder}" />

                <xsl:variable name="genres" select="@genre" />
                <xsl:variable name="seriesId" select="@movie-series" />
                <xsl:variable name="unparsedCover" select="media/cover/@source" />

                <!-- Проверка дали филмът отговаря на филтъра по жанр -->

                <xsl:if test="(($filterOn = 'series') and ($filterValue = $seriesId)) or ($filterOn = 'genre' and contains($genres, $filterValue)) 
                 or ($filterOn = '')">                    
                    <div class="movie-card" id="{@id}">
                        <div class="cover img-fluid rounded-k" style="background-image:url('{$unparsedCover}')"></div>
                        <div class="py-1">
                            <h3>
                                <xsl:value-of select="details/title" />
                                <small class='font-weight-500'>
                                    <xsl:text>(</xsl:text>
                                    <xsl:value-of select="details/year" />
                                    <xsl:text>)</xsl:text>
                                </small>
                            </h3>
                            <p>
                                <xsl:text>Rating: </xsl:text>
                                <xsl:value-of select="details/rating" />
                                <xsl:text> / 10</xsl:text>
                            </p>
                            <div class="align-bottom-right">
                                <button class="btn btn-primary showMoreBut" onclick="showHotelInfo('{@id}')">Show more info</button>
                            </div>
                        </div>
                    </div>
                        
                </xsl:if>
            </xsl:for-each>
        </div>
    </xsl:template>

    <xsl:template name="single-movie">
        <xsl:variable name="genreId" select="/movie_catalog/movies/movie[@id=$showId]/@genre" />
        <xsl:variable name="seriesId" select="/movie_catalog/movies/movie[@id=$showId]/@movie-series" />
        <xsl:variable name="unparsedCover" select="/movie_catalog/movies/movie[@id=$showId]/media/cover/@source" />
        <xsl:variable name="unparsedTrailer" select="/movie_catalog/movies/movie[@id=$showId]/media/trailer/@source" />
        <!-- <xsl:variable name="trailerEntity" select="@source"/> -->
        <span><xsl:value-of select="unparsed-entity-uri($unparsedTrailer)" /></span>

        <div>
            <div class="d-flex flex-column single-movie-holder">
                <h1 class="heading-l mb-5">
                    <xsl:value-of select="/movie_catalog/movies/movie[@id=$showId]/details/title"/>
                    <small class='font-weight-500'>
                        <xsl:text>(</xsl:text>
                        <xsl:value-of select="/movie_catalog/movies/movie[@id=$showId]/details/year" />
                        <xsl:text>)</xsl:text>
                    </small>
                    <span class="p-2" />
                </h1>
                <div class="d-flex">
                    <div id="carouselAutoplaying" class="carousel slide col-6" data-bs-ride="carousel">
                        <div class="carousel-inner">
                            <div class="carousel-item active">
            
                                <div class="cover img-fluid rounded-k" style="background-image:url('{$unparsedCover}')"></div>
                            </div>
                            <xsl:for-each select="/movie_catalog/movies/movie[@id=$showId]/media/gallery/image">
                                <xsl:variable name="unparsedImage" select="@source"/>
                                <div class="carousel-item">
                                    <div class="cover img-fluid rounded-k" style="background-image:url('{$unparsedImage}')"></div>
                                </div>
                            </xsl:for-each>
                        </div>
                        <button class="carousel-control-prev" type="button" data-bs-target="#carouselAutoplaying" data-bs-slide="prev">
                            <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                            <span class="visually-hidden">Previous</span>
                        </button>
                        <button class="carousel-control-next" type="button" data-bs-target="#carouselAutoplaying" data-bs-slide="next">
                            <span class="carousel-control-next-icon" aria-hidden="true"></span>
                            <span class="visually-hidden">Next</span>
                        </button>
                    </div>

                    <div class="info">
                        <div class="mb-4 d-flex justify-content-end">
                            <xsl:call-template name="process-genres">
                                <xsl:with-param name="genres" select="/movie_catalog/movies/movie[@id=$showId]/@genre" />
                            </xsl:call-template>
                        </div>
                        <div>
                            <span class="font-weight-600"><xsl:text>Summary:</xsl:text></span>
                            <p><xsl:value-of select="/movie_catalog/movies/movie[@id=$showId]/details/summary"/></p>
                        </div>
                        <xsl:if test="$seriesId != ''">
                            <p>
                                <span class="font-weight-600"><xsl:text>Part of: </xsl:text></span>
                                <xsl:value-of select="/movie_catalog/movie-series/series[@id=$seriesId]" />
                            </p>
                        </xsl:if>
                        <p>
                            <span class="font-weight-600"><xsl:text>Rating: </xsl:text></span>
                            <xsl:value-of select="/movie_catalog/movies/movie[@id=$showId]/details/rating" />
                            <xsl:text> / 10</xsl:text>
                        </p>
                        <p>
                            <span class="font-weight-600"><xsl:text>Duration: </xsl:text></span>
                            <xsl:value-of select="/movie_catalog/movies/movie[@id=$showId]/details/duration" />
                            <xsl:text> min</xsl:text>
                        </p>
                        <p>
                            <span class="font-weight-600"><xsl:text>Language: </xsl:text></span>
                            <xsl:value-of select="/movie_catalog/movies/movie[@id=$showId]/details/language" />
                        </p>
                        <p>
                            <span class="font-weight-600"><xsl:text>Filmed in: </xsl:text></span>
                            <xsl:value-of select="/movie_catalog/movies/movie[@id=$showId]/details/country" />
                        </p>
                        <div>
                            <xsl:call-template name="process-studios">
                                <xsl:with-param name="studios" select="/movie_catalog/movies/movie[@id=$showId]/@studio" />
                            </xsl:call-template>
                        </div>
                        <p>
                            <span class="font-weight-600"><xsl:text>Budget: </xsl:text></span>
                            <xsl:value-of select="/movie_catalog/movies/movie[@id=$showId]/details/budget" />
                        </p>
                        <div class="d-flex justify-content-end">
                            <button class="btn btn-primary" onclick="showAllHotels()">Show all movies</button>
                        </div>

                    </div>
                </div>
                <div class="trailer">
                    <iframe width="100%" height="700" src="{$unparsedTrailer}" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin"></iframe>
                </div>
                <div class="people-holder">
                    <div class="cast">
                        <h1 class='mb-3 heading-l'>Cast:</h1>
                        <xsl:call-template name="process-actors">
                            <xsl:with-param name="actors" select="/movie_catalog/movies/movie[@id=$showId]/@actor" />
                        </xsl:call-template>
                    </div>
                    <div class="creators">
                        <h1 class='mb-3 heading-l'>Creators:</h1>
                        <xsl:call-template name="process-directors">
                            <xsl:with-param name="directors" select="/movie_catalog/movies/movie[@id=$showId]/@director" />
                        </xsl:call-template>
                        <xsl:call-template name="process-writers">
                            <xsl:with-param name="writers" select="/movie_catalog/movies/movie[@id=$showId]/@writer" />
                        </xsl:call-template>
                        <xsl:call-template name="process-producers">
                            <xsl:with-param name="producers" select="/movie_catalog/movies/movie[@id=$showId]/@producer" />
                        </xsl:call-template>
                        <xsl:call-template name="process-other_creators">
                            <xsl:with-param name="other_creators" select="/movie_catalog/movies/movie[@id=$showId]/@other_creator" />
                        </xsl:call-template>
                    </div>
                </div>
            </div>
         
        </div>
    </xsl:template>

    <xsl:template name="genreShow">
        <xsl:param name="genreId"/>
        <span>
            <xsl:value-of select="/movie_catalog/genres/genre[@id=$genreId]" />
        </span>
    </xsl:template>

    <!-- Шаблон да показване на жанровете -->
    <xsl:template name="process-genres">
        <xsl:param name="genres" />
        <xsl:if test="string-length($genres) > 0">
            <!-- Extract the first genre ID -->
            <xsl:variable name="currentGenre" select="substring-before(concat($genres, ' '), ' ')" />
            <div class="genre mx-2 py-2 px-3">
                <xsl:value-of select="/movie_catalog/genres/genre[@id=$currentGenre]" />
            </div>
            <!-- Process remaining genres -->
            <xsl:call-template name="process-genres">
                <xsl:with-param name="genres" select="normalize-space(substring-after($genres, ' '))" />
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <!-- Шаблон за студиата -->
    <xsl:template name="process-studios">
        <xsl:param name="studios" />
        <xsl:if test="string-length($studios) > 0">
            <xsl:variable name="currentStudio" select="substring-before(concat($studios, ' '), ' ')" />
            <p>
                <span class="font-weight-600"><xsl:text>Studio: </xsl:text></span>
                <xsl:value-of select="/movie_catalog/studios/studio[@id=$currentStudio]" />
            </p>
            <xsl:call-template name="process-studios">
                <xsl:with-param name="studios" select="normalize-space(substring-after($studios, ' '))" />
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <!-- Шаблон за актьорския състав -->
    <xsl:template name="process-actors">
        <xsl:param name="actors" />
        <xsl:if test="string-length($actors) > 0">
            <xsl:variable name="currentActor" select="substring-before(concat($actors, ' '), ' ')" />
            <span class="heading-s font-weight-600">
                <xsl:value-of select="/movie_catalog/actors/actor[@id=$currentActor]/character" />: 
            </span>
            <xsl:call-template name="process-person">
                <xsl:with-param name="personPath" select="/movie_catalog/actors/actor[@id=$currentActor]" />
            </xsl:call-template>
            <xsl:call-template name="process-actors">
                <xsl:with-param name="actors" select="normalize-space(substring-after($actors, ' '))" />
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <!-- Шаблон за режисьор -->
    <xsl:template name="process-directors">
        <xsl:param name="directors" />
        <xsl:if test="string-length($directors) > 0">
            <xsl:variable name="currentDirector" select="substring-before(concat($directors, ' '), ' ')" />
            <span class="heading-s font-weight-600">
                Director: 
            </span>
            <xsl:call-template name="process-person">
                <xsl:with-param name="personPath" select="/movie_catalog/directors/director[@id=$currentDirector]" />
            </xsl:call-template>
            <xsl:call-template name="process-directors">
                <xsl:with-param name="directors" select="normalize-space(substring-after($directors, ' '))" />
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <!-- Шаблон за сценарист -->
    <xsl:template name="process-writers">
        <xsl:param name="writers" />
        <xsl:if test="string-length($writers) > 0">
            <xsl:variable name="currentWriter" select="substring-before(concat($writers, ' '), ' ')" />
            <span class="heading-s font-weight-600">
                Writer: 
            </span>
            <xsl:call-template name="process-person">
                <xsl:with-param name="personPath" select="/movie_catalog/writers/writer[@id=$currentWriter]" />
            </xsl:call-template>
            <xsl:call-template name="process-writers">
                <xsl:with-param name="writers" select="normalize-space(substring-after($writers, ' '))" />
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <!-- Шаблон за продуцент -->
    <xsl:template name="process-producers">
        <xsl:param name="producers" />
        <xsl:if test="string-length($producers) > 0">
            <xsl:variable name="currentProducer" select="substring-before(concat($producers, ' '), ' ')" />
            <span class="heading-s font-weight-600">
               Producer: 
            </span>
            <xsl:call-template name="process-person">
                <xsl:with-param name="personPath" select="/movie_catalog/producers/producer[@id=$currentProducer]" />
            </xsl:call-template>
            <xsl:call-template name="process-producers">
                <xsl:with-param name="producers" select="normalize-space(substring-after($producers, ' '))" />
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <!-- Шаблон за друг създател -->
    <xsl:template name="process-other_creators">
        <xsl:param name="other_creators" />
        <xsl:if test="string-length($other_creators) > 0">
            <xsl:variable name="currentCreator" select="substring-before(concat($other_creators, ' '), ' ')" />
            <span class="heading-s font-weight-600">
                <xsl:value-of select="/movie_catalog/other_creators/other_creator[@id=$currentCreator]/@type" />
            </span>
            <xsl:call-template name="process-person">
                <xsl:with-param name="personPath" select="/movie_catalog/other_creators/other_creator[@id=$currentCreator]" />
            </xsl:call-template>
            <xsl:call-template name="process-other_creators">
                <xsl:with-param name="other_creators" select="normalize-space(substring-after($other_creators, ' '))" />
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <!-- Шаблон за човек -->
    <xsl:template name="process-person">
        <xsl:param name="personPath" />
        <ul>
            <span class="font-weight-600"><xsl:text>Name: </xsl:text></span>
            <xsl:value-of select="$personPath/person/first_name" /> 
            <xsl:value-of select="$personPath/person/last_name" />
            <br/>
            <span class="font-weight-600"><xsl:text>Age: </xsl:text></span>
            <xsl:value-of select="$personPath/person/age" />
            <br/>
            <span class="font-weight-600"><xsl:text>Gender: </xsl:text></span>
            <xsl:value-of select="$personPath/person/gender" />
            <br/>
            <li>
                <span class="font-weight-600"><xsl:text>
                    Also in:
                </xsl:text></span>
                <xsl:call-template name="process-involvement">
                    <xsl:with-param name="involvement" select="$personPath/person/involvement/@movie_refs" />
                </xsl:call-template>
            </li>
        </ul>
    </xsl:template>

    <!-- Шаблон за involvement искам само заглавието на всеки филм -->
    <xsl:template name="process-involvement">
        <xsl:param name="involvement" />
        <xsl:if test="string-length($involvement) > 0">
            <xsl:variable name="currentMovie" select="substring-before(concat($involvement, ' '), ' ')" />
            <!-- to do  -->
            <span class="color-primary"><xsl:value-of select="/movie_catalog/movies/movie[@id=$currentMovie]/details/title" />; </span>
            <xsl:call-template name="process-involvement">
                <xsl:with-param name="involvement" select="normalize-space(substring-after($involvement, ' '))" />
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>