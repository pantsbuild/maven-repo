<?xml version="1.0"?>

<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:pom="http://maven.apache.org/POM/4.0.0">

  <xsl:output method="text"/>

  <xsl:template match="/">
    <xsl:apply-templates select="pom:project/pom:dependencies/pom:dependency[
                                   starts-with(pom:groupId, 'com.twitter.common')
                                 ]"/>
  </xsl:template>

  <xsl:template match="pom:dependency">
    <xsl:value-of select="pom:groupId"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="pom:artifactId"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="pom:version"/>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>
</xsl:stylesheet>
