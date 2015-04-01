<?xml version="1.0"?>

<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:pom="http://maven.apache.org/POM/4.0.0">

  <xsl:output method="text"/>

  <xsl:template match="/">
    <xsl:apply-templates select="pom:project/pom:dependencies/pom:dependency"/>
  </xsl:template>

  <xsl:template match="pom:dependency">
    <xsl:variable name="org" select="pom:groupId"/>
    <xsl:if test="starts-with($org, 'com.twitter.common')">
      <xsl:value-of select="pom:groupId"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="pom:artifactId"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="pom:version"/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
