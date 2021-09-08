<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY menubar SYSTEM 'ddb-menubar'>
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">
<!-- 
*    MB 2001-01-23 Original version
*    MB 2001-02-07 Provide for "banner" menu insertion
*    MB 2001-02-25 Handle revised dict/dictrefs structures
*    MB 2001-02-26 Specify full Unicode font for Basic meaning text
*    MB 2001-09-09 Show resp on sense and trans if not Charles Muller
*    MB 2002-03-26 Treat <title> and @title_entry as equivalent to <text> and @text_entry 
*    CM 2002-03-26 Update HTML styles to be like XHTML 1.0 Strict 
*    CM 2002-11-18 Remove MSArial Unicode Specification
*    MB 2003-06-14 Add variant display toggle feature
*    CM 2003-06-19 Add quotes, title, and paragraph rendering like TEI.2
*    CM 2003-07-04 Add Creative Commons logo
*    CM 2003-07-06 Show source on sense
*    CM 2003-08-26 Added styles for <biblStruct>; added endnote handler
*    CM 2003-09-26 Changed Creative Commons License back to standard copyright
*    CM 2004-10-09 Show source with resp
*    CM 2005-02-23 Added External Hyperlinking via <xsl:template match="xref[@url]">
*    CM 2006-06-06 Added Chinese font family to <a href>">
*    CM 2006-12-12 Added bibl to <xsl:if test="text() or quote">
*    CM 2007-01-06 Added show/hide for rendering the resp attribute of the <trans> node
*    CM 2007-02-20 Remove Chinese font names from <a href> style attributes (browsers support these automatically now.
*    CM 2007-10-18 Added the attribute <xref allindex=""> to link to entries which do not yet exist in the DDB but do exist in Allindex.
                   MB 2010-08-09 Superseded by new xref handler, which automatically creates allindex links as needed.M
*    CM 2007-12-30 Added the rendering of lang attribute for <sense> to enable display of language for French supplied by Swanson.
*    CM 2008-01-30 Added CSS style to apply TXR to the whole document, so that TXR displays right in MS-Word.
*    CM 2008-08-20 Added <lg> and <l> elements.
*    CM 2008-11-12 Added <table> and related elements.
*    CM 2009-01-05 Added Links to Monier-Williams
*    MB 2010-08-19 Modified to handle de-activated internal xrefs and xrefs to authorities data
*    MB 2010-08-20 Handle links to CJKV-E
*    MB 2010-10-27 [RECOVER] Modify user comments invocation
*    MB 2010-10-27 [RECOVER] Start move to external css styling
*    CM 2010-11-29 Added style for <lb/>    
*    CM 2011-01-20 Added display of most recent update.
*                  MB 2012-05-10 Modified so we don't display update date if there wasn't one yet
*    CM 2011-09-07 Added link to INBUDS search.
*    MB 2012-05-19 Added handler for links to Karashima's Lokakṣema
      glossary (see comments ad loc)
*    CM 2012-05-23 Moved <author>, <editor>, and other <biblStruct>-specific
     children to  biblStruct.xsl" to be shared with the rest of my style sheets
*    CM 2013-04-20 Moved the contents of biblStruct.xsl back into ddb.xsl due 
     to some oXygen compatability problem that I can't solve.
*    CM 2014-02-28 Added code to handle bibScope@type="issue"
*    CM 2016-05-11 Changed lang="" attributes to xml:lang="".
*    CM 2016-07-27 Added <ref> node to handle external links for compatibility
     with my other stylesheets.
*    CM 2016-08-13 added @corresp to <bibl> to make links to CTEXT project
*    CM 2018-11-20 show trans@resp when not(Charles Muller or cmuller)
-->


<!-- A sheet-global variable that would let us identify it
*    as belonging to a specific file, if we needed to. 
-->
<xsl:variable name="ourhibyte">not-set</xsl:variable>

<!-- Our css file -->
<xsl:variable name="css">/css/dicts.css</xsl:variable>

<!-- Here we set up variables to help construct our internal
*    xref targets. For the time being, these targets have to
*    obey the syntax expected by my server-side XPointer
*    handler. When true XPointer-aware clients and servers
*    become common, all we need change are these variables
*    in this sheet. The files themselves can stay untouched.
-->
<xsl:variable name="cgipref">/cgi-bin/xpr-ddb.pl?</xsl:variable>
<xsl:variable name="dealt-cgipref">/cgi-bin/xpr-dealt.pl?</xsl:variable>
<xsl:variable name="allindex-cgipref">/cgi-bin/authorities?q=</xsl:variable>
<xsl:variable name="xpathpref">+id('</xsl:variable>
<xsl:variable name="xpathsuf">')</xsl:variable>
<xsl:variable name="xmlsuf">+format=xml</xsl:variable>

<!-- This variable determines the way the readings section is labelled -->
<xsl:variable name="rdglabel">Pronunciations</xsl:variable>
<xsl:variable name="commentslabel">Feedback</xsl:variable>
<!-- Original sheet resumes here -->

<xsl:template match="ddb">
<html>
<head>
      <meta charset="utf-8"/>
     <meta name="viewport" content="width=device-width, initial-scale=1"/>

<!-- Some script to toggle the display of the element whose id is passed in -->
  <script type="text/javascript">
    function toggle(id) 
      {
        element = document.getElementById(id);
        if (element.style.display == 'none') 
         {
           element.style.display = 'block';
         } 
        else
         {
          element.style.display = 'none';
        }
    }
  </script>

<link rel="stylesheet" type="text/css" href="{$css}"/><xsl:text>&#13;</xsl:text>


<xsl:variable name="orth"><xsl:value-of select="entry/hdwd"/></xsl:variable>
<xsl:variable name="transwd"><xsl:value-of select="entry/sense_area/trans"/></xsl:variable>
<title>DDB: <xsl:value-of select="$orth"/> | <xsl:value-of select="$transwd"/></title>
</head>
<body class="ddb-body">
    <xsl:apply-templates select="entry"/>
</body>
</html>

    </xsl:template>

<xsl:template match="entry">

<!-- Get update info for display at bottom of output document 
-->

<xsl:variable name="created"><xsl:value-of select="@add_date"/></xsl:variable>
<xsl:variable name="revised"><xsl:value-of select="@update"/></xsl:variable>

<!-- Get our entry into a variable so we can build a link
*    to the plain xml version 
-->
<xsl:variable name="ourid"><xsl:value-of select="@ID"/></xsl:variable>
<xsl:variable name="hibyte"><xsl:value-of select="substring($ourid,2,2)"/></xsl:variable>


<p class="ddb-head">Digital Dictionary of Buddhism</p>


<div class="ddb-menubar">&menubar;<xsl:call-template  name="writelink2"><xsl:with-param  name = "linktext">
<xsl:value-of select="'XML source'"/>
</xsl:with-param>
<xsl:with-param name="target">
<xsl:value-of select="concat($cgipref,$hibyte,'.xml',$xpathpref,$ourid,$xpathsuf,$xmlsuf)"/>
</xsl:with-param>
</xsl:call-template></div><hr/>

<xsl:apply-templates select = "hdwd"/>

<xsl:if test="//refsonly">

<h4>Sorry, but the DDB does not yet have an entry for this term <span class="dealt-hook">.</span> <br/>You may wish to consult the following external reference(s):</h4>

</xsl:if>
<xsl:apply-templates select = "pron_list"/>
<xsl:apply-templates select = "sense_area"/>
<xsl:apply-templates select = "compounds"/>
<xsl:if test="dictref/dict">
<p class="ddb-dictref-label">[Dictionary References] </p>
  <xsl:for-each select="dictref/dict">
    <p class="ddb-dictrefs">
      <xsl:for-each select="title">
        <xsl:apply-templates />
      </xsl:for-each>
<xsl:for-each select="page"><xsl:text> </xsl:text><xsl:apply-templates />     
      </xsl:for-each>
    </p>
  </xsl:for-each>
</xsl:if>
<hr/>
<p class = "ddb-copyright-label">Copyright provisions</p>
<p class = "ddb-copyright-notice">The rights to textual segments (nodes) of the DDB
are owned by the author indicated in the brackets next to each
segment. For rights regarding the compilation as a whole, please
contact Charles Muller. Please do not reproduce without permission. And <span class = "bold-red">please do not copy into Wikipedia without proper citation!</span></p>
<hr/>
<p class="update-notice">Entry created: <xsl:value-of select="$created"/></p>
<!-- MB 2012-05-10 Don't display an updated notice if there wasn't an update yet -->
<xsl:if test="$revised != ''"><p class="update-notice">Updated: <xsl:value-of select="$revised"/></p></xsl:if>
<hr/>
</xsl:template>

    <xsl:template match="hdwd">
<p class="ddb-hdwd">
    <xsl:value-of select="."/>
</p>

    </xsl:template>

   <xsl:template match="pron_list">
      <span onclick="toggle('readings');return false;"><a href="#"><xsl:value-of select="$rdglabel"/></a></span>   
      <div id="readings" style="display: none;">
   <xsl:for-each select="pron">
       <xsl:if test="@system">[<xsl:value-of select="@system"/>]</xsl:if>
<xsl:choose>
<xsl:when test="@type='recon'">
  <xsl:if test="not(preceding-sibling::pron[@type='recon'])">
    <p style="font-weight:bold; margin-bottom:0">Reconstructed Pronunciations</p>
  <p style="margin-top:0; margin-bottom:0;line-height: 1.0"><xsl:value-of select="."/>
</p></xsl:if>
  <xsl:if test="preceding-sibling::pron[@type='recon']"><p style="margin-top:0; margin-bottom:0;line-height: 1.0"><xsl:value-of select="."/>
    </p></xsl:if>
</xsl:when>
<xsl:otherwise>
  <xsl:value-of select="."/>

     <xsl:if test="@initial">
       (initial = <xsl:value-of select="@initial"/>)
     </xsl:if>
      <br/>
</xsl:otherwise>
</xsl:choose>
	</xsl:for-each>

	</div>
    </xsl:template>
 
<xsl:template match="sense_area">
<br/><br/> 
 <xsl:for-each select="trans"><span class="ddb-basic-meaning">
Basic Meaning: <xsl:value-of select="."/></span>
<xsl:if test="@rend='show'"><xsl:variable name="responsible" select="@resp"/>-->
<!--   <xsl:if test="not(@resp='Charles Muller' or @resp='cmuller')"><xsl:variable name="responsible" select="@resp"/>-->
[<xsl:value-of select="$responsible"/>]</xsl:if>
<br/>
<p style="text-decoration:underline">Senses:</p>
</xsl:for-each>

<!-- MB we must have an apply-templates here for the actual list element, 
*    not just a value-of, otherwise we shan't recurse into
*    the child elements
-->
<xsl:for-each select="sense">
<xsl:if test="text() or quote or bibl or list or xref">
  <xsl:variable name="language" select="@lang"/>
  <xsl:variable name="responsible" select="@resp"/>
  <xsl:variable name="origin" select="@orig"/>
<li class="ddb-sense">
<xsl:choose>
<xsl:when test="xref/@type='lokaksema'">
Cf. Karashima (Lokakṣema Glossary): 
</xsl:when>
</xsl:choose>

<xsl:if test="@lang">[<xsl:value-of select="$language"/>]</xsl:if>
  <xsl:if test="@orig">[<xsl:value-of select="$origin"/>]</xsl:if>
<xsl:text> </xsl:text><xsl:apply-templates/><xsl:text> </xsl:text>
<xsl:if test="@resp and not(@type='autoadd')"> [<xsl:value-of select="$responsible"/>
<xsl:if test="@source">; source(s): <xsl:value-of select="@source"/></xsl:if>]</xsl:if>
</li>

<!-- SAT and INBUDS LINK GENERATOR -->
<!--- The next bit won't execute unless we are at the last (or only) sense -->

<xsl:if test="not(following-sibling::sense)">
    <li><xsl:variable name="satfirst">http://21dzk.l.u-tokyo.ac.jp/SAT2018/key:</xsl:variable>
<a class="ddb-satref"><xsl:attribute name="href"><xsl:value-of select="$satfirst"/><xsl:value-of select="ancestor::entry/hdwd"/></xsl:attribute>Search SAT</a>
  </li>
</xsl:if>

<xsl:if test="not(following-sibling::sense)">
<li>
<xsl:variable name="inbuds">http://21dzk.l.u-tokyo.ac.jp/INBUDS/search.php?m=sch&amp;uekey=</xsl:variable>
<a class="ddb-satref"><xsl:attribute name="href"><xsl:value-of select="$inbuds"/><xsl:value-of select="ancestor::entry/hdwd"/></xsl:attribute>Search INBUDS Database</a>
</li>
</xsl:if>

<!-- END OF SAT LINK GENERATOR -->

</xsl:if>
</xsl:for-each>
<xsl:if test="//note[@place='end']">
  <hr/>
<p class="ddb-notes-label">Notes</p>
<xsl:for-each select="//note[@place='end']">
<xsl:apply-templates  select="."  mode="shownotes"/>
</xsl:for-each>
  <hr/>
</xsl:if>


<!-- Footnote rendering invocation ends-->

<!-- Comments form begins-->

<br/> <span onclick="toggle('comments');return false;"><a href="#" style="text-decoration:none"><xsl:value-of select="$commentslabel"/></a></span>
     <div id="comments" style="display: none;">
    <form action="/cgi-bin/ddb-comments" name="DDB User Comment">
    <p>Send your comment on this entry to the editor.</p>
    <br/>
Name:  <input type="text" name="uname" size="20"/><br/>
Email:  <input type="text" name="email" size="20"/><br/>
Comment:<br/> <textarea name="comment" rows="10" value="$hdwd" cols="50" wrap="true">[<xsl:value-of select="ancestor::entry/hdwd"/>]
</textarea>
      <input type="submit" value="Submit Comment"/>
    <input type="reset" value="Reset"/>

  </form></div>

<!-- Comments form ends-->

</xsl:template>

<xsl:template match="compounds"><p class = "dealt-compounds-label">[Compounds] </p>
    <xsl:apply-templates/>
  </xsl:template>


 <xsl:template match="note">
  <xsl:choose>   
   <xsl:when test="@place='bibl'">
    <xsl:apply-templates/>.&#160;
   </xsl:when>
   <xsl:when test="@rend='paren'">
    <xsl:text> </xsl:text><span style="font-style:normal">(<xsl:apply-templates/>)</span>
   </xsl:when>
   <xsl:when test="@rend='brackets'">
    [<xsl:apply-templates/>]
   </xsl:when>
   <xsl:when test="parent::biblStruct">
    <xsl:apply-templates/>
   </xsl:when>
   <xsl:when test="parent::imprint">
    <!-- for theses and dissertations -->
    <xsl:apply-templates/>, 
   </xsl:when>
  </xsl:choose>
  
 </xsl:template>
<!-- Footnote handler starts -->

<xsl:template match="note[@place='end']">

<!-- First, count our note. This can be tricky if the desired reference markers
*    aren't sequential Arabic numerals, or if the numbering has to restart,
*    eg on each page or within each section. But here there's a continuous
*    sequence throughout the document, so a simple count will do
*    Since we need this value for link creation as well as simple output
*    we put it in a variable
-->
   <xsl:variable name="notenum" select="count(preceding::note[@place='end'])+1"/>

<!--
   Now we need to create an identifier for this note, so that we can link to 
*  and from it. The most general way is to use XSLT's generate-id() function.
*  This returns a string that uniquely identifies a given node. So we could
*  call it here where the note is referenced to generate the href value
*  for the link, then call it again from the same node when in "shownotes" 
*  mode (see below) to create the #name target of the link. But the 
*  resulting html isn't so easy to follow if manual post-editing becomes
*  necessary, so let's just use the actual footnote number as the
*  identifier for the link. However, that would break if at some stage we
*  wanted to start renumbering the notes at each section boundary (since
*  we'd then have more than one note 1 etc.) So let's keep that possiblity
*  open by creating the identifier from the parent section number as well as
*  the running note count.
-->

<!-- Get the section number into a variable -->
<xsl:variable name="secnum" select="ancestor::div1[1]/@n"/>

<!-- Some styling to control the appearance of the reference -->
    <span class="superscript">
<!-- Create our identifier from the two components and put it in a variable -->
<xsl:variable name="linklabel" select="concat($secnum,'-',$notenum)"/>
<!-- Now to write the anchor and hyperlink -->
<!-- We need an <a> element with name and href attributes
* The name will become the target of the hyperlink back to this point
* at the end of the footnote text. The href is, of course, the identifier of
* the target footnote text. We will write a corresponding name into the 
* footnote to form the target of this link when we process it in "shownotes"
* mode
--> 
<a>
<xsl:attribute name="name">refpoint-<xsl:value-of select="$linklabel"/></xsl:attribute>
<xsl:attribute name="href">#note-<xsl:value-of select="$linklabel"/></xsl:attribute>
<xsl:value-of select="$notenum"/>
</a>    
</span><xsl:text> </xsl:text>

<!--  We're done for now: we DON'T do an <xsl:apply-templates/>
*     because that would append the text of the footnote to the reference
*     point we've just inserted, and we don't want that text here.
-->
</xsl:template>


<!-- MB 2003-03-21
*  The second handler, with mode shownotes set,
*  generates :
*  an auto-generated note number [see caveat in comment to body-text
*  note template about relative merits of calculated and hard-coded numbering]
*  an anchor name, as the target of the hyperlink already inserted into the 
*  running text
*  the actual text of the footnote
*  a hyperlink back to the reference point in the body text
 -->

<xsl:template match="note[@place='end']" mode="shownotes">

   <xsl:variable name="notenum" select="count(preceding::note[@place='end'])+1"/>
<p class="note">
<!-- Output the reference no -->
<xsl:value-of select="$notenum"/><xsl:text>. </xsl:text>
<!-- write the <a>element target for the link reference
*   See comments in body-text note handler for the variables and their
*    uses.
-->
<xsl:variable name="secnum" select="ancestor::div1[1]/@n"/>
<xsl:variable name="linklabel" select="concat($secnum,'-',$notenum)"/>
<a>
<xsl:attribute name="name">note-<xsl:value-of select="$linklabel"/></xsl:attribute>
</a>    
   <xsl:apply-templates/>
<!-- Now add a backlink to the body text reference point -->
<xsl:text>[</xsl:text><a>
<xsl:attribute name="href">#refpoint-<xsl:value-of select="$linklabel"/>
</xsl:attribute>
<xsl:text>back</xsl:text>
</a><xsl:text>]</xsl:text>    
</p>

</xsl:template>


<!-- CM styles for sense content area...
-->

<!-- Named templates -->
  <!-- <xsl:template name="Sanskrit-wrap">
   <xsl:param name="contents">
     <xsl:apply-templates/>
   </xsl:param>
   <xsl:choose>
     <xsl:when test="@lang='sa'">
       <span style="font-family: 'Calibri'">
         <xsl:copy-of select="$contents"/>
       </span>
     </xsl:when>
     <xsl:otherwise>
       <xsl:copy-of select="$contents"/>
     </xsl:otherwise>
   </xsl:choose>
</xsl:template>
-->

<xsl:template match="foreign"> 
<span class ="foreign"><xsl:apply-templates/></span> 
</xsl:template>

<xsl:template match="lb">
<br/><xsl:apply-templates/>
</xsl:template>

<!-- The next piece links to anchors created in the Monier-Williams Sanskrit dictionary.
If Unicode http support was working on Pair, we could have created the link based directly on the Sanskrit term, 
but since diacritical characters are corrupted, we needed to create arbitrary id number (as anchors) and link to them.
-->

<xsl:template match="term">
<xsl:choose>
<xsl:when test="@lang='sa-mw'"> 
<xsl:variable name="baseurl">http://buddhism-dict.net/ddb/monier-williams/mw-</xsl:variable>
<xsl:variable name="firsttwo" select="substring(@n, 1, 2)"/> 
<xsl:variable name="sktid" select="@n"/>
<a class="ddb-m-w-link"><xsl:attribute name="href"><xsl:value-of select="$baseurl"/><xsl:value-of select="$firsttwo"/>.html#<xsl:value-of select="$sktid"/></xsl:attribute><xsl:attribute name="class">ddb-m-w-link</xsl:attribute><xsl:apply-templates/></a>
</xsl:when>
<xsl:otherwise><span class="ddb-sanskrit-nolink"><xsl:apply-templates/></span>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
  
  <xsl:template match="placeName">
    <xsl:choose>
      <xsl:when test="@lang='sa-mw'"> 
        <xsl:variable name="baseurl">http://buddhism-dict.net/ddb/monier-williams/mw-</xsl:variable>
        <xsl:variable name="firsttwo" select="substring(@n, 1, 2)"/> 
        <xsl:variable name="sktid" select="@n"/>
        <a class="ddb-m-w-link"><xsl:attribute name="href"><xsl:value-of select="$baseurl"/><xsl:value-of select="$firsttwo"/>.html#<xsl:value-of select="$sktid"/></xsl:attribute><xsl:attribute name="class">ddb-m-w-link</xsl:attribute><xsl:apply-templates/></a>
      </xsl:when>
      <xsl:otherwise><xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="persName">
    <xsl:choose>
      <xsl:when test="@lang='sa-mw'"> 
        <xsl:variable name="baseurl">http://buddhism-dict.net/ddb/monier-williams/mw-</xsl:variable>
        <xsl:variable name="firsttwo" select="substring(@n, 1, 2)"/> 
        <xsl:variable name="sktid" select="@n"/>
        <a class="ddb-m-w-link"><xsl:attribute name="href"><xsl:value-of select="$baseurl"/><xsl:value-of select="$firsttwo"/>.html#<xsl:value-of select="$sktid"/></xsl:attribute><xsl:attribute name="class">ddb-m-w-link</xsl:attribute><xsl:apply-templates/></a>
      </xsl:when>
      <xsl:otherwise><xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<xsl:template match="p">
<xsl:choose>
<xsl:when test="@rend='indent'">
    <p class="indent">
      <xsl:apply-templates/>
    </p>
    </xsl:when>
<xsl:when test="@rend='bq'">
    <p class="bq">
      <xsl:apply-templates/>
    </p>
</xsl:when>
  <xsl:when test="@rend='head1'">
    <p style="text-align:center; font-weight:bold; margin-top:1em; margin-bottom:1em; text-indent:0mm; text-decoration: underline">
      <xsl:apply-templates/>
    </p>
  </xsl:when> 
  <xsl:when test="@rend='head2'">
    <p style="margin-top:1em; margin-bottom:1em; text-indent:0mm; margin-right:2mm;text-decoration: underline">
      <xsl:apply-templates/>
    </p>
  </xsl:when>  
  <xsl:when test="@rend='head-bold'">
    <p class="head-bold">
      <xsl:apply-templates/>
    </p>
  </xsl:when>  
  <xsl:otherwise>
          <p>
      <xsl:apply-templates/>
          </p>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

  <xsl:template match="xref[@canonref]">
    <xsl:variable name="hlink" select="@canonref"/>
<a href="{$hlink}" class="ddb-canonref" target="_blank"><xsl:apply-templates/></a>
  </xsl:template>

<!--  ADDED 2012-05-19   MB  -->

<!-- Handlers for xref with type='lokaksemsa':
     If rend='iframe', embed the referenced glossary item in an iframe
     otherwise insert a standard hyperlink.
     Homographs are a complication. If we see an n value on the xref
     we know we have two or more homographs needing appropriate rendering.
     (= Insert a line break before the first iframe (only) and a homograph 
     number before each link)
-->

  <xsl:template match="xref[@type='lokaksema']">
  <xsl:variable name="hlink" select="@target"/>
  <xsl:variable name="thisnum" select="@n"/>
  <xsl:variable name="this_id" select="generate-id()"/>

  <xsl:choose>
  <xsl:when test = "@rend='iframe'">
    <xsl:if test='$thisnum = 1'><br/>&#xa0;&#xa0;</xsl:if>
    <xsl:if test='$thisnum'>(<xsl:value-of select='$thisnum'/>) </xsl:if>
    <a href="#" onclick="toggle('{$this_id}');return false;" style="cursor: pointer;" class="gloss_link">view / hide</a>
    <!-- height, width and b/g colour of the iframe are set in /css/dicts.css. However, we *must* set the display style inline here.  -->
    <div><iframe  class='lokaksema' scrolling="auto" style="display: none" src="{$hlink}" id="{$this_id}">ENTRY</iframe></div>
  </xsl:when>
  <xsl:otherwise>
    <xsl:if test='$thisnum'>(<xsl:value-of select='$thisnum'/>) </xsl:if>
  
    <a href="{$hlink}" class="lokaksema_ref" target="_blank"><xsl:apply-templates/></a>
  </xsl:otherwise>
  </xsl:choose>
  </xsl:template>

<!--  END OF 2012-05-19  ADDITIONS  -->
  
<xsl:template match="emph">
   <xsl:choose>
     <xsl:when test="@rend='bold'">
   <span style="font-weight:bold"><xsl:apply-templates/></span>       
     </xsl:when>
     <xsl:otherwise>
    <span style="font-style:italic"><xsl:apply-templates/></span>       
     </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<xsl:template match="hi">
   <xsl:choose>
     <xsl:when test="@rend='bold'">
   <span style="font-weight:bold"><xsl:apply-templates/></span>       
     </xsl:when>
     <xsl:when test="@rend='italic'">
   <span style="font-style:italic"><xsl:apply-templates/></span>       
     </xsl:when>
     <xsl:when test="@rend='ul'">
       <span style="text-decoration:underline"><xsl:apply-templates/></span>       </xsl:when>
     <xsl:otherwise>
    <span style="font-weight:bold"><xsl:apply-templates/></span>       
     </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<xsl:template match="sup">
  <span class="superscript"><xsl:apply-templates/></span>
</xsl:template>

<xsl:template match="quote[@rend='brackets']">
  <span style="font-family: MingLiU, Simsun, Mincho">「<xsl:apply-templates/>」</span>
</xsl:template>
<xsl:template match="quote[@rend='bq']">
    <p
     style="margin-left:10mm; margin-top:0.5em; margin-bottom:1em; text-indent:0mm; margin-right:2mm; font-size:12pt;">
     <xsl:apply-templates/>
    </p>
</xsl:template>
<xsl:template match="quote[@rend='dq']">
 &quot;<xsl:apply-templates/>&quot;
</xsl:template>
  <xsl:template match="quote[@rend='sq']">
 '<xsl:apply-templates/>'
</xsl:template>
<xsl:template match="soCalled">
 &apos;<xsl:apply-templates/>&apos;
</xsl:template>

<xsl:template match="bibl">
   <xsl:choose>
     <xsl:when test="@type='canonref'">
       <xsl:choose>
         <xsl:when test="@corresp">
           〔<xsl:apply-templates/>
           <xsl:variable name="ctextfirst">http://ctext.org/</xsl:variable>
           <xsl:variable name="ctextend">?searchu=</xsl:variable>

<!--  CM original version
           <a style="font-size:80%; font-weight:bold; text-decoration:none"><xsl:attribute name="href"><xsl:value-of select="$ctextfirst"/><xsl:value-of select="@corresp"/><xsl:value-of select="$ctextend"/><xsl:value-of select="ancestor::entry/hdwd"/></xsl:attribute> [ctext]</a>〕
-->
<!--  MB: construct href value using attribute value templates (arguably more readable/maintainable) -->

           <a style="font-size:80%; font-weight:bold; text-decoration:none" href="{$ctextfirst}{@corresp}{$ctextend}{ancestor::entry/hdwd}"> [ctext]</a>〕

         </xsl:when>
         <xsl:otherwise> 
       〔<span style="font-style:normal; font-family: 'ＭＳ Ｐ明朝', 'MS PMincho', 'ヒラギノ明朝 Pro W3', 'メイリオ', Meiryo, serif"><xsl:apply-templates/></span>〕
         </xsl:otherwise>
       </xsl:choose>
     </xsl:when>
      <xsl:when test="parent::listBibl">
  <p style="text-indent:-10mm;margin-left:10mm; margin-top: 0; margin-bottom: 0">
      <xsl:apply-templates/>
    </p>      
      </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>  
     </xsl:otherwise>
 </xsl:choose>
  
  </xsl:template>

 <xsl:template match="date">
  <xsl:choose>
   <xsl:when test="(parent::p)">
    <xsl:apply-templates/>
   </xsl:when>
   <xsl:otherwise>
    <xsl:apply-templates/>. </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
 
  
    <xsl:template match="title">
        <xsl:choose>
            <xsl:when test="ancestor::listBibl">
                <xsl:choose>
                    <xsl:when
                        test="@level='m' or @level='s'">
                        <xsl:choose>
                            <xsl:when test="parent::title[@level='m']">
                                <span style="font-style:normal">
                                    <xsl:apply-templates/>
                                </span>
                            </xsl:when>
                            <xsl:when test="parent::title[@level='a']">
                                <span style="font-style:italic">
                                    <xsl:apply-templates/>
                                </span>
                            </xsl:when>
                            <xsl:when test="parent::ref">
                                <span style="font-style:italic">
                                    <xsl:apply-templates/>
                                </span>
                            </xsl:when>
                            <xsl:when test="parent::title[@level='u']">
                                <span style="font-style:italic">
                                    <xsl:apply-templates/>
                                </span>
                            </xsl:when>
                            <xsl:when test="parent::gloss[@xml:lang='en']">
                                <span style="font-style:italic">
                                    <xsl:apply-templates/>
                                </span>
                            </xsl:when>
                            <xsl:when test="following-sibling::imprint/biblScope[@unit='vol']">
                                <span style="font-style:italic">
                                    <xsl:apply-templates/>.
                                </span>
                                <xsl:text> </xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <span style="font-style:italic"><xsl:apply-templates/>. </span>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                  <xsl:when
                    test="@level='j'">
                    <span style="font-style:italic"><xsl:apply-templates/> </span>
                  </xsl:when>
                    <xsl:when test="@type='parallel'">(<xsl:apply-templates/>) </xsl:when>
                    <xsl:when
                        test="@level='a' or @level='u' or parent::analytic or ancestor::biblStruct[@type='thesis']">
                        <xsl:choose>
                            <xsl:when test="child::gloss[@xml:lang='en']"> &#x201c;<xsl:apply-templates/>
                            </xsl:when>
                            <xsl:when test="substring(., string-length(.)) = '.'">
                                &#x201c;<xsl:apply-templates/>&#x201d;</xsl:when>
                            <xsl:when test="substring(., string-length(.)) = '?'">
                                &#x201c;<xsl:apply-templates/>&#x201d;</xsl:when>
                            <xsl:when test="substring(., string-length(.)) = ','">
                                &#x201c;<xsl:apply-templates/>&#x201d;</xsl:when>
                            <xsl:otherwise>&#x201c;<xsl:apply-templates/>.&#x201d;&#160;</xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="@rend='dbrackets'">『<xsl:apply-templates/>』</xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    
                    <!-- Outside of <listBibl> -->
                    <xsl:when test="@level='m' or @level='j' or @level='s' or parent::monogr or parent::bibl">
                        <span style="font-style:italic"><xsl:apply-templates/></span></xsl:when>
                    <xsl:when test="@level='a' or @level='u'"> &#x201c;<xsl:apply-templates/>&#x201d;</xsl:when>
                    <xsl:otherwise>
                        <span style="font-style:italic">
                            <xsl:apply-templates/>
                        </span>
                    </xsl:otherwise>
                    
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
 
    <xsl:template match="idno"></xsl:template>

  <xsl:template match="gloss">
    <xsl:choose>
      <xsl:when test="parent::title or parent::author or parent::editor">
        <xsl:choose>
            <xsl:when test="@lang='sa' or @xml:lang='sa' ">
              <span style="font-style:italic"> (<xsl:apply-templates/>)</span>
            </xsl:when>
          <xsl:when test="@xml:lang='ja'">
            <span style="font-style:normal; font-family: 'ＭＳ Ｐ明朝', 'MS PMincho', 'ヒラギノ明朝 Pro W3', 'メイリオ', Meiryo, serif">
              <xsl:apply-templates/><xsl:text> </xsl:text></span>
          </xsl:when>
          <xsl:when test="@xml:lang='zh'">
            <span style="font-style:normal; font-family: 'ＭＳ Ｐ明朝', 'MS PMincho', Tahoma, Arial, Helvetica, Yahei, '微软雅黑', 宋体, SimSun, STXihei, '华文细黑', sans-serif; serif">
              <xsl:apply-templates/><xsl:text> </xsl:text></span>
          </xsl:when>
              <xsl:otherwise>
              <span style="font-style:normal"> (<xsl:apply-templates/>)</span>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
<xsl:otherwise>
  <span style="font-style:normal; font-family: 'ＭＳ Ｐ明朝', 'MS PMincho', Tahoma, Arial, Helvetica, Yahei, '微软雅黑', 宋体, SimSun, STXihei, '华文细黑', sans-serif; serif">
    <xsl:apply-templates/></span>
</xsl:otherwise>
    </xsl:choose>
  </xsl:template>



<!-- MB 2001-01-19
*  Display the radical
*  For this to be useful, the radicals will need to be
*  assigned ids so that they can be xrefed as in your
*  html version. 
-->  
<xsl:template match="radical">
  <p>radical <xsl:value-of select="@glyph"/></p> 
</xsl:template>


<!-- MB 2001-01-19
*    Handle xref elements
-->

<xsl:template match="xref">


<!-- At the moment two conceptually different types of
*    cross-reference are being marked up identically,
*    distinguishable only by an attribute. This makes the
*    code here less that ideally clear, and therefore
*    potentially harder to maintain. Another area where some
*    review of the mark up misght be useful
-->

<!-- First handle a ddb-internal reference, if that's
*    what we have
-->

<xsl:choose>


<xsl:when  test="@allref">


<xsl:call-template  name = "writelink">
  <xsl:with-param  name = "linktext">
 <xsl:value-of select="."/>
  </xsl:with-param>
  <xsl:with-param name="target">

  <xsl:value-of select="concat($allindex-cgipref,@allref)"/>
  </xsl:with-param>
</xsl:call-template>


</xsl:when>

<xsl:when  test="@idref and not(@active ='no') and not(@allref)">


<xsl:variable name="dictcode" select ="substring(@idref,1,1)"/>


<!-- Get the full idref into a variable and chop off the
*    high byte of the code point into another variable
*    so we can build the target file name
-->
<xsl:variable name="thisref"><xsl:value-of select = '@idref'/></xsl:variable>

<xsl:variable name="hibyte"><xsl:value-of select="substring($thisref,2,2)"/></xsl:variable>


<!-- Build an internal hyperlink to our target idref
*    Our callable writelink template does the actual construction
*    and output of the html anchor, but first we have to build
*    the parameters that tell it what the link target is and
*    what text we want for the link display
*    Basically, we build the name of the xml target file using the
*    high byte value we stripped from the idref, plus an Xpointer
*    to the full idref, then we sandwich those in between the
*    components we built at the top of this file to make the
*    desired url
*    MB 2010-08-16 Now we can have internal xrefs across the two dictionary datasets, we need to check the id prefix
-->

<xsl:call-template  name = "writelink">  
  <xsl:with-param  name = "linktext">
 <xsl:value-of select="."/> 
  </xsl:with-param>
  <xsl:with-param name="target">
  <xsl:choose>
  <xsl:when test = "$dictcode = 'b'">
  <xsl:value-of select="concat($cgipref,$hibyte,'.xml',$xpathpref,$thisref,$xpathsuf)"/> 
  </xsl:when>
 <xsl:when test = "$dictcode = 'c'">
 <xsl:value-of select="concat($dealt-cgipref,$hibyte,'.xml',$xpathpref,$thisref,$xpathsuf)"/>
 </xsl:when>
 </xsl:choose>
  </xsl:with-param>	
</xsl:call-template>

</xsl:when>


<!-- MB 2010-08-16  Handle links the indexed has marked as inactive -->
<xsl:when test="@active ='no'">
 <xsl:apply-templates />
</xsl:when>

<xsl:otherwise>

<!-- But if our xref was in fact to an external link, we
*    handle it here.
*    But it would be better to mark up such links in their
*    own right, not a children of an xref element
-->
  <xsl:apply-templates select ="a"/>

</xsl:otherwise>

</xsl:choose>


</xsl:template>


<!-- MB 2001-01-19
*    Retrieve the target and text for the external link
*    and let our callable template write them out 
-->

<xsl:template match="a">
<br/>

<xsl:call-template  name="writelink">  
  <xsl:with-param  name = "linktext">
 <xsl:value-of select="."/> 
  </xsl:with-param>
  <xsl:with-param name="target">
 <xsl:value-of select="@href"/> 
  </xsl:with-param>	
</xsl:call-template>

</xsl:template>

<!-- MB 2001-01-19
*    Callable template to write a hyperlink
*    Params are $target and $linktext

-->

<xsl:template name="writelink">
<xsl:param name="target"/>
<xsl:param name="linktext"/>
	<a  style="text-decoration: none;font-family:Mincho,MingLiU,Batang,Simsun"><xsl:attribute name="href"><xsl:value-of select="$target"/>
	</xsl:attribute>
	<xsl:value-of select="$linktext"/></a>
</xsl:template>


<!-- MB 2001-02-15
*    Callable template to write a hyperlink with a _blank target
*    Params are $target and $linktext
-->

<xsl:template name="writelink2">
<xsl:param name="target"/>
<xsl:param name="linktext"/>
<a style="font-family:Mincho,MingLiU,Batang,Simsun"><xsl:attribute name="href"><xsl:value-of select="$target"/>	</xsl:attribute><xsl:attribute name="target"><xsl:value-of select="'_blank'"/></xsl:attribute>	<xsl:value-of select="$linktext"/></a></xsl:template>

<xsl:template match="dict">
<p style="text-indent:5mm; margin-top:0em; margin-bottom:0em; line-height:1.2em"><xsl:value-of select="@name"/><xsl:value-of select="."/></p>
</xsl:template>
    
    <!-- ref (1) To select a bracketed URL -->
    
    <xsl:template match="ref[@type='url']">
        <xsl:variable name="url" select="."/>
        <a href="{$url}"><xsl:apply-templates/></a>
        
    </xsl:template>
    
    <!-- ref (2) To take the target attribute as the URL to be appled to bracketed text -->
    
    <xsl:template match="ref[@target]"><xsl:variable name="hlink" select="@target"/><a href="{$hlink}"><xsl:apply-templates/></a></xsl:template>
    
    <xsl:template match="ref[@rend]"><xsl:variable name="hlink" select="@rend"/><a href="{$hlink}"><xsl:apply-templates/></a></xsl:template>
    
    <!-- ref (3) Same structure as above, using ptr and target, like Sebastian does -->
    
    <xsl:template match="ptr[@target]">
        <xsl:variable name="hlink" select="@target"/>
        <a href="{$hlink}"><xsl:apply-templates/></a>
    </xsl:template>
    
    <!-- anchors -->
    
    <xsl:template match="anchor[@xml:id]">
        <xsl:variable name="location" select="@xml:id"/>
        <a id="{$location}"><xsl:apply-templates/></a>
    </xsl:template>

<!-- CM 2003-06-18
*  List handler to render lists to numbered, bulleted
* and plain ("simple").
-->

 <xsl:template match="list">
     <xsl:choose>
<xsl:when test="@type='bulleted'">
 <ul style="list-style-type: disc">
<xsl:for-each select="item">
<li><xsl:apply-templates/></li>
</xsl:for-each>
</ul>
</xsl:when>
<xsl:when test="@type='ordered'">
  <ol>
    <xsl:apply-templates/>
</ol>
</xsl:when>
<xsl:when test="@type='simple'">
 <ul style="list-style-type: none">
<xsl:for-each select="item">
<li><xsl:apply-templates/></li>
</xsl:for-each>
</ul>
</xsl:when>
     <xsl:when test="@type='ordered-upper-roman'">
        <ol style="list-style-type:upper-roman">
<xsl:apply-templates/>
        </ol>
      </xsl:when>
<xsl:otherwise>
  <ul style="list-style-type: disc">
<xsl:apply-templates/>
</ul>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

  <xsl:template match="item">
    <li style="margin-bottom: 0.5em">
      <xsl:apply-templates/>
    </li>
  </xsl:template>
  <xsl:template match="label">
    <xsl:choose>
      <xsl:when test="@rend='italic'">
        <span style="font-style:italic">
          <xsl:apply-templates/>
        </span>
      </xsl:when>
      <xsl:when test="@rend='bold'">
        <span style="font-weight:bold">
          <xsl:apply-templates/>
        </span>
      </xsl:when>
      <xsl:when test="@rend='underline'">
        <span style="text-decoration:underline">
          <xsl:apply-templates/>
        </span>
      </xsl:when>
      <xsl:when test="@rend='underline-colon'">
        <span style="text-decoration:underline"><xsl:apply-templates/>: </span>
      </xsl:when>
      <xsl:when test="@rend='color-red'">
        <span style="color: rgb(204, 0, 0); font-weight:bold">[<xsl:apply-templates/>]</span>
      </xsl:when>
      <xsl:when test="@rend='brackets'"> [<xsl:apply-templates/>]<xsl:text> </xsl:text>
      </xsl:when>
     
      <xsl:when test="@rend='brackets-bold-par'">
        <p style="margin-bottom:0em; font-weight:bold">[<xsl:apply-templates/>]</p>
      </xsl:when> 
      
      <xsl:when test="@rend='brackets-par'">
        <p style="margin-bottom:0em">[<xsl:apply-templates/>]</p>
      </xsl:when>
      
      <!-- CM 2007-03-12 next structure is for printing out Wonhyo volume
 -->
      <xsl:when test="@rend='brackets-par-hide'"> </xsl:when>
      
      <xsl:otherwise>
        <br/>
        <span style="margin-bottom:0em;margin-left:2em">
          <xsl:apply-templates/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="lg">
    <xsl:choose>
      <xsl:when test="@rend='hide'">
      </xsl:when>
        <xsl:otherwise><p style="margin-top:0em; margin-bottom:2em">     <xsl:apply-templates/></p>
      </xsl:otherwise></xsl:choose>
  </xsl:template>
  
  <xsl:template match="l">
    <p style="margin-top:0; margin-bottom:0; text-indent:10mm; line-height:6mm"><xsl:apply-templates/></p>
  </xsl:template>

<xsl:template match="table">
    <xsl:choose>
    <xsl:when test="@rend='fullwidth'">
  <table style="width: 100"><xsl:apply-templates/></table>
    </xsl:when>
    <xsl:when test="@rend='90'">
  <table style="width: 90" border="2"><xsl:apply-templates/></table>
    </xsl:when>
    <xsl:when test="@rend='80'">
  <table style="width: 80" border="1"><xsl:apply-templates/></table>
    </xsl:when>
    <xsl:when test="@rend='50'">
  <table style="width: 50" border="1"><xsl:apply-templates/></table>
    </xsl:when>
    <xsl:otherwise>
 <table><xsl:apply-templates/></table>
</xsl:otherwise></xsl:choose>
</xsl:template>

<xsl:template match="row">
  <tr><xsl:apply-templates/></tr>
</xsl:template>
<xsl:template match="cell">
  <td style="text-align: left"><xsl:apply-templates/></td>
</xsl:template>
    
 <!--   <xsl:include href="biblStruct.xsl"/>-->
    
 <!-- Bibliographical renderings -->
<xsl:template match="listBibl">
  <xsl:choose>
    <xsl:when test="@rend='classics'">
      <xsl:for-each select="biblStruct">
        <xsl:sort select="descendant::title[1]"/>       
        <p style="text-indent:-10mm;margin-left:10mm; margin-bottom:0">
          <xsl:if test="@n">
            <span style="font-weight:bold;margin-left:2mm">
              <xsl:value-of select="@n"/>
              <xsl:text>-&#x09;</xsl:text>
            </span>
          </xsl:if>
          <xsl:apply-templates/>
        </p>
      </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <xsl:for-each select="biblStruct">
        <xsl:sort select="descendant::surname[1]"/>
          <!--     <p style="text-indent:-10mm;margin-left:10mm; line-height: 200%">-->
          <p style="text-indent:-10mm;margin-left:10mm; margin-bottom:0; margin-top:0">
          <xsl:if test="@n">
            <span style="font-weight:bold;margin-left:2mm">
              <xsl:value-of select="@n"/>
              <xsl:text>-&#x09;</xsl:text>
            </span>
          </xsl:if>
          <xsl:apply-templates/>
        </p>
      </xsl:for-each>      

      <xsl:for-each select="bibl">
        <p style="text-indent:-10mm;margin-left:10mm;margin-top:0; margin-bottom:0">
          <xsl:apply-templates/>
        </p>
      </xsl:for-each>      
      
    </xsl:otherwise>
  

  </xsl:choose>

</xsl:template>
 <xsl:template match="analytic">

  <xsl:apply-templates select="author"/>
     <xsl:apply-templates select="../monogr/imprint/date"/>
  <xsl:apply-templates select="title"/>
     <xsl:if test="following-sibling::monogr/title[@level='m']"><xsl:text> In </xsl:text>
     </xsl:if>
 </xsl:template>


  <xsl:template match="monogr">
    <xsl:choose>
      <xsl:when test="ancestor::listBibl[@rend='classics']">
        <xsl:apply-templates select="title"/>
        <xsl:apply-templates select="author"/>
        <xsl:apply-templates select="editor"/>
        <xsl:apply-templates select="imprint/biblScope"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="author"/>
        <xsl:apply-templates select="editor"/>
        <xsl:if test="not(preceding-sibling::analytic)">
          <xsl:apply-templates select="imprint/date"/>
        </xsl:if>
        <xsl:apply-templates select="title"/>
        <xsl:if test="preceding-sibling::analytic">
       <!--   <xsl:apply-templates select="imprint/biblScope[@unit='pp']"/>-->
        </xsl:if>
       <xsl:apply-templates select="imprint/note"/>
        <xsl:apply-templates select="imprint/pubPlace"/>
        <xsl:apply-templates select="imprint/publisher"/>
     <!--   <xsl:if test="not(preceding-sibling::analytic)">-->
          <xsl:apply-templates select="imprint/biblScope"/>
        <!--</xsl:if>-->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
    
   <xsl:template match="imprint">
        <xsl:choose>
            <xsl:when test="ancestor::monogr[1]/title[@level='j']">
                <xsl:apply-templates select="biblScope[@unit='vol']"/>
                <xsl:apply-templates select="biblScope[@unit='issue']"/>
                <xsl:apply-templates select="biblScope[@unit='pp']"/>
            </xsl:when>  
            <xsl:when test="ancestor::monogr[1]/title[@level='m']">
	      <xsl:apply-templates select="biblScope[@unit='vols']"/>
            <xsl:apply-templates select="biblScope[@unit='pp']"/>
              <xsl:apply-templates select="pubPlace"/>
              <xsl:apply-templates select="publisher"/>
      
          </xsl:when>  
          <xsl:when test="ancestor::listBibl[1][@rend='classics']">
            <xsl:apply-templates select="biblScope[@unit='fascicles']"/>
            <xsl:apply-templates select="biblScope[@unit='canonref']"/>
          </xsl:when>  
            <xsl:otherwise>
                <xsl:apply-templates select="pubPlace"/>
                <xsl:apply-templates select="publisher"/>
         
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


 <xsl:template match="monogr[@rend]">
  <xsl:variable name="monogrnote" select="@rend"/>
  <xsl:value-of select="$monogrnote"/>
  <xsl:text> </xsl:text>
  <xsl:apply-templates/>
 </xsl:template>

 <xsl:template match="imprint[@rend]">
  <xsl:variable name="imprintnote" select="@rend"/> [<xsl:value-of select="$imprintnote"
  /><xsl:text>: </xsl:text><xsl:apply-templates/>] </xsl:template>


  <xsl:template match="author">
  
    <!-- MB 2003-08-01 
      
** If our author name is the same as the
     preceding one, output a string of dashes in its place. NB
     this presupposes that identical names are indeed entered
     identically! It might also be a wise precaution to
     normalize-space both the string values we are
     comparing. Also, the "suppression marker" perhaps ought to
     be in a variable rather than hard-coded as here.
-->
    
    <xsl:variable name="fname" select="child::forename"/>
    
    <xsl:choose>

      <xsl:when
       test="preceding::biblStruct[1]/*/editor[1] = . or preceding::biblStruct[1]/*/author[1] = .">
        <xsl:choose>
           <xsl:when test="preceding::bibl[1]/author = .">
            <xsl:text>----.&#160;</xsl:text>
          </xsl:when>
          <xsl:when test="preceding::bibl[1]/editor = .">
            <xsl:text>----.&#160;</xsl:text>
          </xsl:when>
          <xsl:when test="preceding::bibl[1]/*/author = .">
            <xsl:text>----.&#160;</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>----.&#160;</xsl:text>
          </xsl:otherwise>
          </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        
        <xsl:choose>
          <xsl:when test="child::surname">
            <xsl:choose>
              <xsl:when test="preceding-sibling::author">
                  <xsl:choose>
                      <xsl:when test="not(following-sibling::author)">
                          <xsl:text>and </xsl:text>
                          <xsl:value-of select="forename"/>
                          <xsl:text>&#160;</xsl:text>
                          <xsl:value-of select="surname"/>
                          <xsl:text>.&#160;</xsl:text>
                      </xsl:when>
                      <xsl:otherwise>
                          <xsl:value-of select="forename"/>
                          <xsl:text>&#160;</xsl:text>
                          <xsl:value-of select="surname"/>
                          <xsl:text>,&#160;</xsl:text>
                      </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:when test="following-sibling::author">
                    <xsl:value-of select="surname"/>, <xsl:value-of select="forename"
                    /><xsl:text>,&#160;</xsl:text>
                </xsl:when>
                <xsl:when test="substring($fname, string-length($fname)) = '.'">
                    <xsl:value-of select="surname"/>, <xsl:value-of select="forename"
                    /><xsl:text>&#160;</xsl:text>
                </xsl:when>
              <xsl:when test="ancestor::biblStruct[@xml:lang='ea' or @lang='ea']">
                <xsl:value-of select="surname"/><xsl:text>&#160;</xsl:text><xsl:value-of select="forename"
                /><xsl:if test="child::gloss"><xsl:text>&#160;</xsl:text><span style="font-family: 'ＭＳ 明朝', Simsun, Batang; font-style:normal"><xsl:value-of select="gloss"/></span></xsl:if><xsl:text>.&#160;</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="surname"/><xsl:if test="child::forename">, <xsl:value-of select="forename"/></xsl:if><xsl:text>.&#160;</xsl:text>
              </xsl:otherwise>
              
            </xsl:choose>
          </xsl:when>
          <xsl:when test="child::name">
            <xsl:apply-templates/>
            <xsl:text>.&#160;</xsl:text>
          </xsl:when>
          <xsl:when test="substring(., string-length(.)) = '.'">
            <xsl:apply-templates/>
            <xsl:text>&#160;</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
            <xsl:text>.&#160;</xsl:text>            
          </xsl:otherwise>
        </xsl:choose>
        
      </xsl:otherwise>
        </xsl:choose>
  </xsl:template>
    
    <xsl:template match="editor">
      <xsl:variable name="edfname" select="child::forename"/>
    <xsl:choose>
      <xsl:when
        test="preceding::biblStruct[1]/*/editor = . or preceding::biblStruct[1]/*/author = .">
        <xsl:choose>
          <xsl:when test="@role='trans'">
            <xsl:text>----, trans.&#160;</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="following-sibling::editor">
                <xsl:text>---- and </xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>----, ed.&#160;</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="@role='trans'">
          <xsl:choose>
              <xsl:when test="child::surname">
                  <xsl:choose>
                      <xsl:when test="preceding-sibling::editor">
                          <xsl:choose>
                              <xsl:when test="not(following-sibling::editor)">
                                  <xsl:text>and </xsl:text>
                                  <xsl:value-of select="forename"/>
                                  <xsl:text>&#160;</xsl:text>
                                  <xsl:value-of select="surname"/>
                                  <xsl:text>, trans.&#160;</xsl:text>
                              </xsl:when>
                              <xsl:otherwise>
                                  <xsl:value-of select="forename"/>
                                  <xsl:text>&#160;</xsl:text>
                                  <xsl:value-of select="surname"/>
                                  <xsl:text>,&#160;</xsl:text>
                              </xsl:otherwise>
                          </xsl:choose>
                      </xsl:when>
                      <xsl:otherwise>
                          <xsl:choose>
                              <xsl:when test="following-sibling::editor">
                                  <xsl:value-of select="surname"/>, <xsl:value-of select="forename"
                                  /><xsl:text>,&#160;</xsl:text>
                              </xsl:when>
                            <xsl:otherwise>
                              <xsl:value-of select="surname"/><xsl:if test="child::forename">, <xsl:value-of select="forename"/></xsl:if><xsl:text>, trans.&#160;</xsl:text>
                            </xsl:otherwise>
                          </xsl:choose>
                      </xsl:otherwise>
                  </xsl:choose>
              </xsl:when>
          </xsl:choose>
      </xsl:when>
         <xsl:otherwise>
        <xsl:choose>
            <xsl:when test="child::surname">
                <xsl:choose>
                    <xsl:when test="preceding-sibling::editor">
                        <xsl:choose>
                            <xsl:when test="not(following-sibling::editor)">
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="forename"/>
                                <xsl:text>&#160;</xsl:text>
                                <xsl:value-of select="surname"/>
                                <xsl:text>, eds.&#160;</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="forename"/>
                                <xsl:text>&#160;</xsl:text>
                                <xsl:value-of select="surname"/>
                                <xsl:text>,&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                        <xsl:when test="following-sibling::editor">
                            <xsl:value-of select="surname"/>, <xsl:value-of select="forename"
                            /><xsl:text>,&#160;</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="surname"/><xsl:if test="child::forename">, <xsl:value-of select="forename"
                        /></xsl:if><xsl:text>, ed.&#160;</xsl:text>
                    </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

 <xsl:template match="monogr[@rend]">
  <xsl:variable name="monogrnote" select="@rend"/>
  <xsl:value-of select="$monogrnote"/>
  <xsl:text> </xsl:text>
  <xsl:apply-templates/>
 </xsl:template>

 <xsl:template match="imprint[@rend]">
  <xsl:variable name="imprintnote" select="@rend"/> [<xsl:value-of select="$imprintnote"
  /><xsl:text>: </xsl:text><xsl:apply-templates/>] </xsl:template>

 <xsl:template match="edition">
  <xsl:apply-templates/>
  <xsl:text>. </xsl:text>
 </xsl:template>

 <xsl:template match="pubPlace">
     <xsl:choose>
         <xsl:when test="ancestor::monogr/title[@level='u']">
             <xsl:apply-templates/>. 
         </xsl:when>
         <xsl:otherwise>
                 <xsl:apply-templates/>:&#160;
         </xsl:otherwise>
     </xsl:choose>
 </xsl:template>
 
 <xsl:template match="publisher">
<xsl:choose>
 <xsl:when test="ancestor::monogr[1]/title[@level='j']"><xsl:apply-templates/>&#160;
</xsl:when>
<xsl:otherwise>
<xsl:apply-templates/>.
</xsl:otherwise>
</xsl:choose>
 </xsl:template>
  
  <xsl:template match="date">
    <xsl:choose>
      <xsl:when test="(parent::p)">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>. </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
 <xsl:template match="biblScope">
  <xsl:choose>
   <xsl:when test="ancestor::listBibl">
    <xsl:choose>
      <xsl:when test="@unit='vol' or @unit='volume'">
      <xsl:choose>
       <xsl:when test="ancestor::monogr[1]/title[@level='j']"
         >&#160;<xsl:apply-templates/>&#160;</xsl:when>
        <xsl:when test="ancestor::monogr[1]/title[@level='m']"
          >vol. <xsl:apply-templates/><xsl:text> </xsl:text></xsl:when>
       <xsl:otherwise> <xsl:apply-templates/>, 
       </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
            <xsl:when test="@unit='vols'">
    <xsl:apply-templates/>&#160;vols. </xsl:when>
       <xsl:when test="@unit='pp' or @unit='pages'">
      <xsl:choose>
       <xsl:when test="ancestor::monogr[1]/title[@level='j']">: <xsl:apply-templates/>. </xsl:when>
       <xsl:when test="ancestor::monogr[1]/title[@level='m']"><xsl:apply-templates/>. </xsl:when>
       <xsl:otherwise>pp. <xsl:apply-templates/>. </xsl:otherwise>
      </xsl:choose>
     </xsl:when>
     <xsl:when test="@unit='canonref'">
      <xsl:apply-templates/>. </xsl:when>
      <xsl:when test="@unit='fascicles'">
        <xsl:apply-templates/>, </xsl:when>
     <xsl:when test="@unit='issue'">(<xsl:apply-templates/>)</xsl:when>
     <xsl:otherwise>
      <xsl:apply-templates/>
      <xsl:text> </xsl:text>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:when>
   <xsl:when test="ancestor::cit | ancestor::p | ancestor::quote | ancestor::lg">
    (<xsl:apply-templates/>) </xsl:when>
   <xsl:otherwise>
    <xsl:apply-templates/>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

</xsl:stylesheet>

