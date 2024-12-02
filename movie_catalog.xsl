<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/ XSL/Transform">
    <!-- ШАБЛОНИ ТОЗИ Е ЗА ROOT -->
    <xsl:template match="/"> ... </xsl:template>
    <!-- селектира преките наследници на message -->
    <xsl:value-of select="message"/>
</xsl:stylesheet>