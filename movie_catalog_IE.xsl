<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" indent="yes" doctype-public="-//W3C//DTD HTML 4.01//EN" doctype-system="http://www.w3.org/TR/html4/strict.dtd" />

    <xsl:template match="/">
        <html lang="en">
            <head>
                <meta charset="utf-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1" />
                <title>Movie catalogue</title>
                <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/css/bootstrap.min.css" />
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" />
                <link rel="stylesheet" href="./dist/css/main.min.css" />
                <style>
                    .movie-list {
                        display: block;
                        overflow:hidden;
                        margin: auto;
                    }
                    .movie-list .movie-card {
                        width: 18%;
                        display: block;
                        float: left;
                        margin-right: 2%;
                        height: 550px;
                    }
                    .movie-list .movie-card .cover {
                        height: 80%;
                        margin-bottom: 5%;
                    }
                    .movie-list .movie-card .info {
                        width: 100%;
                        padding: 2% 5%;
                    }
                </style>
            </head>
            <body>
                <div id="content" class="p-5">
                    <xsl:call-template name="loadContent" />
                </div>
            </body>
        </html>
    </xsl:template>

    <xsl:template name="loadContent">

        <h1 class="heading-xl mb-5">Movie catalogue</h1>
        
        <div class="movie-list">
            <xsl:for-each select="movie_catalog/movies/movie">

                <xsl:sort select="details/rating" data-type="number" order="descending"/>
                
                <xsl:variable name="genres" select="@genre" />
                        <xsl:variable name="coverImage" select="unparsed-entity-uri(media/cover/@source)" />

                <div class="movie-card mb-5" id="{@id}">
                      
                            <div class="cover" style="background-image:url({$coverImage})"></div>

                            <div class="info">
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
                                <xsl:call-template name="genreShow">
                                    <xsl:with-param name="genreId" select="@id" />
                                </xsl:call-template>
                            </div>
                </div>
            </xsl:for-each>
        </div>
    </xsl:template>

    <xsl:template name="genreShow">
        <xsl:param name="genreId"/>
        <span>
            <xsl:value-of select="/movie_catalog/genres/genre[@id=$genreId]" />
        </span>
    </xsl:template>

</xsl:stylesheet>