<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="html" indent="yes"/>

    <!-- ШАБЛОНИ ТОЗИ Е ЗА ROOT -->
    <xsl:template match="/">
        <html>
            <head>
                <meta charset="UTF-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                <link rel="stylesheet" href="dist/css/main.min.css" />
                <title>Movie Catalog</title>
            </head>

            <body>
                <ul class="menu">
                    <ul class="filter-by">
                        <li>Show All</li>
                        <li>Series</li>
                        <li>Genre</li>
                    </ul>
                    <ul class="series">
                        <!-- here i want to show all different types of series -->
                        <li></li>
                    </ul>
                    <ul class="genres">
                        <!-- here i want to show all different types of genres -->
                        <li></li>
                    </ul>
                    <ul class="sort-by">
                        <li>Alphabethicaly</li>
                        <li>By Year</li>
                        <li>By Rating</li>
                    </ul>
                </ul>
                <div class="container">

                    <div class="movie-list">
                        <xsl:for-each select="movie_catalog/movies/movie">

                            <xsl:variable name="coverImage" select="media/cover/@source " />
                             <xsl:variable name="coverURL">
                                <xsl:value-of select="key('coverKey', $coverImage)"/>
                            </xsl:variable>

                            <!-- movie card for every movie -->
                            <div class="movie-card">
                                <a href="movie_details.html?id={@id}">
                                    <div class="cover" style="width:100px; height:100px; background:url({$coverURL})"></div>

                                    <div class="year-rating-bar">
                                        <p><xsl:value-of select="details/year"/></p>
                                        <div class="icon-star"></div>
                                        <p><xsl:value-of select="details/rating"/></p>
                                    </div>
                                    <h3><xsl:value-of select="title"/></h3>
                                    <p><xsl:value-of select="details/summary"/></p>
                                </a>
                            </div>
                        </xsl:for-each>
                    </div>

                </div>
            </body>
        </html>
    </xsl:template>


                <!-- селектира преките наследници на message -->
            </xsl:stylesheet>