<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <xsl:output method="html" indent="yes"/>
    
    <!-- Parameters for filtering and sorting -->
    <xsl:param name="loadDocument">true</xsl:param>
    <xsl:param name="showAll">true</xsl:param>
    <xsl:param name="showId"></xsl:param>
    <xsl:param name="sortOn"></xsl:param>
    <xsl:param name="sortOrder">ascending</xsl:param>
    <xsl:param name="sortType">text</xsl:param>
    <xsl:param name="filterOn"></xsl:param>
    <xsl:param name="filterValue"></xsl:param>


    <!-- Главен шаблон -->
    <xsl:template match="/">
        <xsl:call-template name="loadDocument">
            <!-- Изберете дали да заредите movie-list или single-movie в зависимост от параметрите в JavaScript -->
            <xsl:with-param name="content" select="'movie-list'" /> <!-- Това е по подразбиране, ако няма параметър id -->
        </xsl:call-template>
    </xsl:template>


    <!-- Шаблон за самият документ -->
    <xsl:template name="loadDocument">
        <xsl:param name="content" />

        <html>
            <head>
                <meta charset="UTF-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
                <link rel="stylesheet" href="dist/css/main.min.css" />
                <title>Movie Catalog</title>
            </head>
            <body>
                <h1 class="heading-xl my-2 t-style-sb">Movie Catalogue</h1>

                <!-- Тук премахваме проверката за параметър id в URL-а, тъй като тя ще се обработва в JavaScript -->
                <xsl:when test="$content = 'single-movie'">
                    <!-- Задаваме параметъра 'id' за конкретния филм -->
                    <xsl:call-template name="single-movie">
                        <xsl:with-param name="id" select="$id" />
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Ако няма параметър id, зареждаме списък с филми -->
                    <xsl:call-template name="movie-list" />
                </xsl:otherwise>

                <div id="output"></div> <!-- Това е мястото, където ще бъде заредено съдържанието -->

                <!-- Проверка за параметър 'id' в URL чрез JavaScript -->
                <script>
                        console.log("HERE");
                    fetch('movie_catalog.xml')
                    .then(response => response.text())
                    .then(xmlString => {
                        var parser = new DOMParser();
                        var xmlDoc = parser.parseFromString(xmlString, "application/xml");

                        var processor = new XSLTProcessor();
                        var xslDoc = document;  // Вашият текущ HTML документ съдържа XSLT

                        processor.importStylesheet(xslDoc);

                        // Проверяваме за параметъра 'id' в URL-а
                        var movieId = new URLSearchParams(window.location.search).get('id');
                        if (movieId) {
                            processor.setParameter(null, 'content', 'single-movie');  // Задаваме съдържанието като 'single-movie'
                            processor.setParameter(null, 'id', movieId);  // Задаваме id на филма
                        } else {
                            processor.setParameter(null, 'content', 'movie-list');  // По подразбиране е 'movie-list'
                        }
                        var resultDocument = processor.transformToDocument(xmlDoc);
                        console.log(resultDocument);
                        if (!resultDocument) return;

                        document.getElementById('output').appendChild(resultDocument.documentElement);
                    })
                    .catch(error => console.error('Error loading XML:', error));

                </script>
            </body>
        </html>
    </xsl:template>


    <!-- Шаблон за всички филми -->
    <xsl:template name="movie-list">
        <ul class="filter-menu d-flex">
            <!-- Genre Filter -->
            <ul class="dropdown">
                <div class="btn">Choose genre:</div>
                <ul class="d-flex-column">
                    <xsl:for-each select="/movie_catalog/genres/genre">
                        <li>
                            <button onclick="filterBy('genre', '{@id}')" class="btn btn-primary">
                                <xsl:value-of select="." />
                            </button>
                        </li>
                    </xsl:for-each>
                </ul>
            </ul>

            <!-- Series Filter -->
            <ul class="dropdown">
                <div class="btn">Choose Series:</div>
                <ul class="d-flex-column">
                    <xsl:for-each select="movie_catalog/movie-series/series">
                        <li>
                            <button onclick="filterBy('series', '{@id}')" class="btn btn-primary">
                                <xsl:value-of select="." />
                            </button>
                        </li>
                    </xsl:for-each>
                </ul>
            </ul>

            <!-- Sort Options -->
            <ul class="dropdown">
                <div class="btn">Order By:</div>
                <ul class="d-flex-column">
                    <li><button onclick="orderBy('title', 'ascending', 'text')" class="btn btn-primary">A-Z</button></li>
                    <li><button onclick="orderBy('title', 'descending', 'text')" class="btn btn-primary">Z-A</button></li>
                    <li><button onclick="orderBy('year', 'ascending', 'number')" class="btn btn-primary">Year ↑</button></li>
                    <li><button onclick="orderBy('year', 'descending', 'number')" class="btn btn-primary">Year ↓</button></li>
                    <li><button onclick="orderBy('rating', 'ascending', 'number')" class="btn btn-primary">Rating ↑</button></li>
                    <li><button onclick="orderBy('rating', 'descending', 'number')" class="btn btn-primary">Rating ↓</button></li>
                    <li><button onclick="orderBy('length', 'ascending', 'number')" class="btn btn-primary">Length ↑</button></li>
                    <li><button onclick="orderBy('length', 'descending', 'number')" class="btn btn-primary">Length ↓</button></li>
                    <li><button onclick="orderBy('budget', 'ascending', 'number')" class="btn btn-primary">Budget ↑</button></li>
                    <li><button onclick="orderBy('budget', 'descending', 'number')" class="btn btn-primary">Budget ↓</button></li>
                </ul>
            </ul>
        </ul>

        <div class="container">
            <div class="movie-list">
                <!-- Filtering movies -->
                <xsl:for-each select="/movie_catalog/movies/movie">
                    <!-- Check if movie matches filter -->
                    <xsl:if test="(
                        ($filterOn = 'genre' and contains(details/genre, $filterValue)) or
                        ($filterOn = 'series' and contains(series, $filterValue)) or
                        ($filterOn = 'studio' and contains(studio, $filterValue)) or
                        ($filterOn = ''))">
                        <xsl:variable name="coverImage" select="unparsed-entity-uri(media/cover/@source)" />
                        <!-- Movie card -->
                            <a href="?id={@id}" class="movie-card">
                            <div class="cover" style="background-image:url({$coverImage})"></div>
                            <h3 class="px-1"><xsl:value-of select="title" /></h3>
                            <div class="year-rating-bar p-1">
                                <p><xsl:value-of select="details/year" /></p>
                                <p><xsl:value-of select="details/rating" />/10</p>
                            </div>
                        </a>
                    </xsl:if>
                </xsl:for-each>
            </div>
        </div>
    </xsl:template>

    <xsl:template name="single-movie">
        <xsl:param name="id" />
        <div class="container">
            <xsl:for-each select="/movie_catalog/movies/movie[@id = $id]">
                <xsl:variable name="coverImage" select="unparsed-entity-uri(media/cover/@source)" />
                <xsl:variable name="img1" select="unparsed-entity-uri(media/cover/@source)" />
                <!-- Movie card -->
                <div class="d-flex-column single-movie-holder">
                    <div class="media">
                        <div id="activeImg" class="cover" style="background-image:url({$coverImage})"></div>
                        <div class="gallery">
                            <div class="cover" style="background-image:url({$coverImage})"></div>
                            <xsl:for-each select="media/gallery/image">
                                <xsl:variable name="currentImage" select="unparsed-entity-uri(@source)" />
                                <div class="cover" style="background-image:url({$currentImage})"></div>
                            </xsl:for-each>
                        </div>
                    </div>
                    <div class="info">
                        <h1><xsl:value-of select="title" /></h1>
                        <div class="genre-holder">
                            <xsl:call-template name="process-genres">
                                <xsl:with-param name="genres" select="@genre" />
                            </xsl:call-template>
                        </div>
                        <div>
                            <h1>Summary:</h1>
                            <p><xsl:value-of select="details/summary"/></p>
                        </div>
                        <div class="details">
                            <h1>Movie details:</h1>
                            <p><xsl:value-of select="details/year"/></p>
                            <p><xsl:value-of select="details/rating"/>/10</p>
                            <p><xsl:value-of select="details/duration"/>min</p>
                            <p><xsl:value-of select="details/language"/></p>
                            <p><xsl:value-of select="details/country"/></p>
                            <p><xsl:value-of select="details/budget"/></p>
                            <div class="studio-holder">
                                <xsl:call-template name="process-studios">
                                    <xsl:with-param name="studios" select="@studio" />
                                </xsl:call-template>
                            </div>
                        
                        </div>
                        <div class="cast">
                            <h1>Cast:</h1>
                            <xsl:call-template name="process-actors">
                                <xsl:with-param name="actors" select="@actor" />
                            </xsl:call-template>
                        </div>
                        <div class="creators">
                            <h1>Creators:</h1>
                            <xsl:call-template name="process-directors">
                                <xsl:with-param name="directors" select="@director" />
                            </xsl:call-template>
                            <xsl:call-template name="process-writers">
                                <xsl:with-param name="writers" select="@writer" />
                            </xsl:call-template>
                            <xsl:call-template name="process-producers">
                                <xsl:with-param name="producers" select="@producer" />
                            </xsl:call-template>
                            <xsl:call-template name="process-other_creators">
                                <xsl:with-param name="other_creators" select="@other_creator" />
                            </xsl:call-template>
                        </div>
                    </div>
                </div>
            </xsl:for-each>
        </div>
    </xsl:template>

    <!-- Шаблон да показване на жанровете -->
    <xsl:template name="process-genres">
        <xsl:param name="genres" />
        <xsl:if test="string-length($genres) > 0">
            <!-- Extract the first genre ID -->
            <xsl:variable name="currentGenre" select="substring-before(concat($genres, ' '), ' ')" />
            <div class="genre">
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
            <b>
                <xsl:value-of select="/movie_catalog/actors/actor[@id=$currentActor]/character" />: 
            </b>
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
            <b>
                Director: 
            </b>
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
            <b>
                Writer: 
            </b>
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
            <b>
               Producer: 
            </b>
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
            <b>
                <xsl:value-of select="/movie_catalog/other_creators/other_creator[@id=$currentCreator]/@type" />
            </b>
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
            <xsl:value-of select="$personPath/person/first_name" /> 
            <xsl:value-of select="$personPath/person/last_name" />,
            <xsl:value-of select="$personPath/person/age" />, 
            <xsl:value-of select="$personPath/person/gender" />
            <br/>
            <li>
                <b>
                    Also in:
                </b>
            </li>
            <xsl:call-template name="process-involvement">
                <xsl:with-param name="involvement" select="$personPath/person/involvement/@movie_refs" />
            </xsl:call-template>
        </ul>
    </xsl:template>

    <!-- Шаблон за involvement искам само заглавието на всеки филм -->
    <xsl:template name="process-involvement">
        <xsl:param name="involvement" />
        <xsl:if test="string-length($involvement) > 0">
            <xsl:variable name="currentMovie" select="substring-before(concat($involvement, ' '), ' ')" />
            <!-- to do  -->
            <a href="singleMovie"> 
                <xsl:value-of select="/movie_catalog/movies/movie[@id=$currentMovie]/title" />; 
            </a>
            <xsl:call-template name="process-involvement">
                <xsl:with-param name="involvement" select="normalize-space(substring-after($involvement, ' '))" />
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <!-- Шаблон за подробности за филм -->
    <xsl:template match="/movie_catalog/movies/movie">
        <html>
            <head>
                <meta charset="UTF-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                <link rel="stylesheet" href="dist/css/main.min.css" />
                <title><xsl:value-of select="title"/> - Movie Details</title>
            </head>
            <body>
                <div class="movie-details">
                    <h1><xsl:value-of select="title" /></h1>
                    <div class="cover">
                        <xsl:variable name="coverImage" select="unparsed-entity-uri(media/cover/@source)" />
                        <img src="{$coverImage}" alt="{title}" />
                    </div>
                    <p><strong>Year:</strong> <xsl:value-of select="details/year" /></p>
                    <p><strong>Rating:</strong> <xsl:value-of select="details/rating" /></p>
                    <p><strong>Genre:</strong>
                        <xsl:for-each select="details/genre">
                            <span><xsl:value-of select="." /></span>
                        </xsl:for-each>
                    </p>
                    <p><strong>Description:</strong> <xsl:value-of select="description" /></p>
                </div>
                <a href="/">Back to Movie List</a>
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>
