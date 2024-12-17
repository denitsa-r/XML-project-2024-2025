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
                <ul class="filter-menu"> Choose filteer:
                    <ul class="genres"> By genre:
                        <!-- here i want to show all different types of genres -->
                        <xsl:for-each select="movie_catalog/genres/genre">
                            <li><xsl:value-of select="."/></li>
                        </xsl:for-each>
                    </ul>
                    <ul> By Series:
                        <!-- here i want to show all different types of series -->
                        <xsl:for-each select="movie_catalog/movie-series/series">
                            <li><xsl:value-of select="."/></li>
                        </xsl:for-each>
                    </ul>
                    <ul> By Country:
                        <!-- here i want to show all different types of series -->
                        <!-- TO DO -->
                        <!-- <xsl:for-each select="movie_catalog/countries/country">
                            <li><xsl:value-of select="."/></li>
                        </xsl:for-each> -->
                    </ul>
                    <ul> By Topic:
                        <!-- TO DO -->
                        <!-- here i want to show all different types of series -->
                        <!-- <xsl:for-each select="movie_catalog/countries/country">
                            <li><xsl:value-of select="."/></li>
                        </xsl:for-each> -->
                    </ul>
                    <ul> By Source:
                        <!-- TO DO -->
                        <!-- here i want to show all different types of series -->
                        <!-- <xsl:for-each select="movie_catalog/countries/country">
                            <li><xsl:value-of select="."/></li>
                        </xsl:for-each> -->
                    </ul>
                    <ul> By Production Company:
                        <!-- TO DO -->
                        <!-- here i want to show all different types of series -->
                        <xsl:for-each select="movie_catalog/movies/movie/production">
                            <li><xsl:value-of select="."/></li>
                        </xsl:for-each>
                    </ul>
                    <div>
                        <ul> Order by:
                            <li>Alphabethicaly</li>
                            <li>Year</li>
                            <li>Rating</li>
                            <li>Lenght</li>
                            <li>Budget</li>
                        </ul>
                    </div>
                </ul>
                <div class="container">

                    <div class="movie-list">
                        <xsl:for-each select="movie_catalog/movies/movie">

                            <xsl:variable name="coverImage" select="unparsed-entity-uri(media/cover/@source)" />

                            <!-- movie card for every movie -->
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


    <!-- селектира преките наследници на message -->
</xsl:stylesheet>