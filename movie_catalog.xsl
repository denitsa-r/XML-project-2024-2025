<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="html" indent="yes"/>

    <!-- показва начален документ -->
    <xsl:param name="loadDocument">true</xsl:param>
    <!-- показва всички -->
    <xsl:param name="showAll">true</xsl:param>
    <!-- показва един филм според ID -->
    <xsl:param name="showId"></xsl:param>
    <!-- управление на сортирането -->
    <xsl:param name="sortOn"></xsl:param>
    <xsl:param name="sortOrder">ascending</xsl:param>
    <xsl:param name="sortType">text</xsl:param>
    <!-- управление на филтрирането -->
    <xsl:param name="filterOn"></xsl:param>
    <xsl:param name="filterValue"></xsl:param>

    <!-- задаваме шаблон за зареждане или на страницата -->
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

    <!-- шаблон за head заглавие -->
    <xsl:template name="loadDocument">
        <html>
            <head>
                <meta charset="UTF-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                <link rel="stylesheet" href="dist/css/main.min.css" />
                <title><xsl:text>Movie Catalogue</xsl:text></title>
            </head>

            <body>
                <h1 class="heading-xl my-2 t-style-sb">Movie Catalogue</h1>
                <div id="content" class="p-5">
                    <xsl:call-template name="loadContent"></xsl:call-template>
                </div>
            </body>
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
                    imageUrlsMap.forEach(e => { document.querySelectorAll(`[src="${e[0]}"]`).forEach(el => el.setAttribute("src",e[1]));
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
                };

                const orderBy = (sortOn, sortOrder, sortType) => {
                    state.sortOn = sortOn;
                    state.sortOrder = sortOrder;
                    state.sortType = sortType;

                    updateContent();
                };

                const filterBy = (filterOn, filterValue) => {
                    state.filterOn = filterOn;
                    state.filterValue = filterValue;

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
                <div id="sortOptionsMenu" class="d-flex col-4 offset-4 justify-content-around mb-5">
                    <div class="dropdown">
                        <button class="btn btn-info dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                            Choose Region
                        </button>
                        <ul class="dropdown-menu">
                            <li>
                                <button onclick="filterBy('','')" class="dropdown-item">All regions</button>
                            </li>
                            <xsl:for-each select="catalogue/regions/region">
                                <li>
                                    <button onclick="filterBy('region','{@id}')" class="dropdown-item">
                                        <xsl:call-template name="regionShow">
                                            <xsl:with-param name="regId" select="@id" />
                                        </xsl:call-template>
                                    </button>
                                </li>
                            </xsl:for-each>

                        </ul>
                    </div>

                    <div class="dropdown">
                        <button class="btn btn-info dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                            Choose Chain
                        </button>
                        <ul class="dropdown-menu">
                            <li>
                                <button onclick="filterBy('','')" class="dropdown-item">All movies</button>
                            </li>
                            <xsl:for-each select="catalogue/series/serie">
                                <li>
                                    <button onclick="filterBy('chain','{@id}')" class="dropdown-item">
                                        <xsl:value-of select="." />
                                    </button>
                                </li>
                            </xsl:for-each>

                        </ul>
                    </div>

                    <div class="dropdown">
                        <button class="btn btn-info dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                            Order by
                        </button>
                        <ul class="dropdown-menu">
                            <li>
                                <button onclick="orderBy('','ascending','text')" class="dropdown-item">Default</button>
                            </li>
                            <li>
                                <button onclick="orderBy('name','ascending','text')" class="dropdown-item">A-Z</button>
                            </li>
                            <li>
                                <button onclick="orderBy('name','descending','text')" class="dropdown-item">Z-A</button>
                            </li>
                            <li>
                                <button onclick="orderBy('rating','ascending','text')" class="dropdown-item">Rating ↑</button>
                            </li>
                            <li>
                                <button onclick="orderBy('rating','descending','text')" class="dropdown-item">Rating ↓</button>
                            </li>
                            <li>
                                <button onclick="orderBy('lenght','ascending','text')" class="dropdown-item">Lenght ↑</button>
                            </li>
                            <li>
                                <button onclick="orderBy('lenght','descending','text')" class="dropdown-item">Lenght ↓</button>
                            </li>
                            <li>
                                <button onclick="orderBy('year','ascending','text')" class="dropdown-item">Year ↑</button>
                            </li>
                            <li>
                                <button onclick="orderBy('year','descending','text')" class="dropdown-item">Year ↓</button>
                            </li>
                            <li>
                                <button onclick="orderBy('budget','ascending','text')" class="dropdown-item">Budget ↑</button>
                            </li>
                            <li>
                                <button onclick="orderBy('budget','descending','text')" class="dropdown-item">Budget ↓</button>
                            </li>
                        </ul>
                    </div>

                </div>

                <ul class="filter-menu d-flex">
                    <ul class="dropdown">
                        <div class="btn">Choose genre:</div>
                            <ul class="d-flex-column">
                                <!-- here i want to show all different types of genres -->
                                <xsl:for-each select="movie_catalog/genres/genre">
                                    <li>
                                        <button class="btn btn-primary" onclick="filterBy('genre','{@id}">
                                            <xsl:value-of select="."/>
                                        </button>
                                    </li>
                                </xsl:for-each>
                            </ul>
                    </ul>
                    <ul class="dropdown"> 
                        <div class="btn">Choose Series:</div>
                        <!-- here i want to show all different types of series -->
                        <ul class="d-flex-column">
                            <xsl:for-each select="movie_catalog/movie-series/series">
                                <li class="btn btn-primary">
                                    <button class="btn btn-primary" onclick="filterBy('series','{@id}">
                                        <xsl:value-of select="."/>
                                    </button>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </ul>
                    <ul class="dropdown">
                        <div class="btn">Choose Studio:</div>
                        <!-- TO DO -->
                        <!-- here i want to show all different types of series -->
                        <ul class="d-flex-column">
                            <xsl:for-each select="movie_catalog/studios/studio">
                                <li class="btn btn-primary">
                                    <button class="btn btn-primary" onclick="filterBy('genre','{@id}">
                                        <xsl:value-of select="."/>
                                    </button>        
                                </li>
                            </xsl:for-each>
                        </ul>
                    </ul>
                    <ul class="dropdown"> 
                        <div class="btn">Order By:</div>
                        <ul class="d-flex-column">
                            <li class="btn btn-primary">Alphabethicaly</li>
                            <li class="btn btn-primary">Year</li>
                            <li class="btn btn-primary">Rating</li>
                            <li class="btn btn-primary">Lenght</li>
                            <li class="btn btn-primary">Budget</li>
                        </ul>
                    </ul>
                </ul>
                <xsl:call-template name="allHotelsTemplate" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="singleHotelTemplate" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

<!-- 
    <xsl:template match="/">
                
                <div class="container">

                    <div class="movie-list">
                        <xsl:for-each select="movie_catalog/movies/movie">

                            <xsl:variable name="coverImage" select="unparsed-entity-uri(media/cover/@source)" />

                            <!- movie card for every movie ->
                            <a href="movie_details.html?id={@id}" class="movie-card">
                                <div class="cover" style="background-image:url({$coverImage})"></div>
                                <h3 class="px-1"><xsl:value-of select="title"/></h3>
                                <div class="year-rating-bar p-1">
                                    <p><xsl:value-of select="details/year"/></p>
                                    <div class="icon-star"></div>
                                    <p><xsl:value-of select="details/rating"/></p>
                                </div>
                            </a>
                        </xsl:for-each>
                    </div>

                </div>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="movie">
        <html>
            <head>
                <meta charset="UTF-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                <link rel="stylesheet" href="dist/css/main.min.css" />
                <title><xsl:value-of select="title"/> - Movie Details</title>
            </head>
            <body>
                <div class="movie-details">
                    <h1><xsl:value-of select="title"/></h1>
                    <div class="cover">
                        <xsl:variable name="coverImage" select="unparsed-entity-uri(media/cover/@source)" />
                        <img src="{$coverImage}" alt="{title}" />
                    </div>
                    <p><strong>Year:</strong> <xsl:value-of select="details/year"/></p>
                    <p><strong>Rating:</strong> <xsl:value-of select="details/rating"/></p>
                    <p><strong>Genre:</strong>
                        <xsl:for-each select="details/genre">
                            <span><xsl:value-of select="."/></span>
                        </xsl:for-each>
                    </p>
                    <p><strong>Description:</strong> <xsl:value-of select="description"/></p>
                </div>
                <a href="/">Back to Movie List</a>
            </body>
        </html>
    </xsl:template>
 -->

    <!-- селектира преките наследници на message -->

</xsl:stylesheet>