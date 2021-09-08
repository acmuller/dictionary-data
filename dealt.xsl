<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY menubar SYSTEM 'dealt-menubar'>
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">
<!-- Modified for XPointer demo by Michael Beddow
*    (mb@mbeddow.net) 2001-01-23
*    (alignment with revised dtd) MB 2001-01-29
*    Revised for shorter cgi invocation format MB 2001-02-05
*    MB 2001-02-07 Provide for "banner" menu insertion
*    MB 2001-02-10 Express dictionary references
*    MB 2001-09-09 Display resp on sense where not Charles Muller
*    CM 2002-04-19 Take Line Breaks away from pronunciations
*    CM 2002-04-19 Add Strict HTML styling for Netscape
*    CM 2002-09-15 Redo dictrefs area like DDB
*    MB 2010-08-12 Recognize and handle xrefs to DDB
*    CM 2010-08-22 Add _initial_ attribute to pron node for Korean
*    CM 2010-08-22 Add handling of compounds element
*    MB 2010-08-19 Modified to handle de-activated internal xrefs and xrefs to authorities data
*    MB 2010-10-27 [RECOVER] Start move to external css styling
*    CM 2010-10-27 Removed variants field, added variant information to sense field.
*    CM 2011-01-20 Added display of most recent update.
*    CM 2011-01-21 Added Feedback form.
*    CM 2011-09-14 Added Link to WWWJDIC and CHISE.
*    CM 2012-05-24 Added Link to biblStruct.xsl.
*    CM 2016-05-11 Changed lang="" to xml:lang=""
*    CM 2016-05-15 Restore @resp value with a view toward abbreviating repetitions
*       in bibliographical style, like .- {incomplete}
*    CM 2016-08-13 added @corresp to <bibl> to make links to CTEXT project
*    CM 2016-09-07 added @resp to be shown when <sense> strings are over 100 characters
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
<xsl:variable name="cgipref">/cgi-bin/xpr-dealt.pl?</xsl:variable>
<xsl:variable name="ddb-cgipref">/cgi-bin/xpr-ddb.pl?</xsl:variable>
<xsl:variable name="xpathpref">+id('</xsl:variable>
<xsl:variable name="xpathsuf">')</xsl:variable>
<xsl:variable name="xmlsuf">+format=xml</xsl:variable>

<xsl:variable name="rdglabel">Pronunciations</xsl:variable>
<xsl:variable name="commentslabel">[Feedback]</xsl:variable>
<!-- Original sheet resumes here -->

<xsl:template match="/">
<html>
<head><meta charset="utf-8"/>
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

<title>CJKV-English Dictionary</title>
</head>

<body class="dealt">

    <xsl:apply-templates/>
</body>

</html>

    </xsl:template>

  <xsl:template match="dealt">
    <xsl:apply-templates/>
  </xsl:template>

 <xsl:template match="entry">

<!-- Get our entry into a variable so we can build a link
*    to the plain xml version 
-->
<xsl:variable name="ourid"><xsl:value-of select="@ID"/></xsl:variable>
<xsl:variable name="hibyte"><xsl:value-of select="substring($ourid,2,2)"/></xsl:variable>
  <xsl:variable name="firstfour"><xsl:value-of select="substring($ourid,2,4)"/></xsl:variable>

<p class = "dealt-head">CJKV-English Dictionary</p>
  
<center>&menubar;<xsl:call-template  name="writelink2"><xsl:with-param  name = "linktext">
<xsl:value-of select="'XML source'"/>
</xsl:with-param>
<xsl:with-param name="target">
<xsl:value-of select="concat($cgipref,$hibyte,'.xml',$xpathpref,$ourid,$xpathsuf,$xmlsuf)"/>
</xsl:with-param>
</xsl:call-template></center><hr></hr>
    <xsl:apply-templates/>

<!-- The following should only function on single-character head words, thus the test for the length of ID -->

  <xsl:if test="string-length($ourid) &lt; 6">
  <p style="font-size:large; color:green;
   family:Calibri;margin-bottom:0">[Further Web References] </p>

    <div><xsl:variable name="wwwjdic">http://nihongo.monash.edu/cgi-bin/wwwjdic?1C</xsl:variable><a class="ddb-satref"><xsl:attribute name="href"><xsl:value-of select="$wwwjdic"/><xsl:value-of select="$firstfour"/></xsl:attribute>WWWDJIC</a></div>

  <div>  
   <xsl:variable name="chise">http://chise.zinbun.kyoto-u.ac.jp/ids-find?components=</xsl:variable>
   <a class="ddb-satref"><xsl:attribute name="href"><xsl:value-of select="$chise"/><xsl:value-of select="hdwd"/></xsl:attribute>Chise IDS Find</a></div>
</xsl:if>



  <xsl:variable name="created"><xsl:value-of select="@add_date"/></xsl:variable>
  <xsl:variable name="revised"><xsl:value-of select="@update"/></xsl:variable>
<hr/> 
<p class="update-notice">Entry created: <xsl:value-of select="$created"/></p>
<!-- MB 2012-05-10 Don't display an updated notice if there wasn't an update yet -->
<xsl:if test="$revised != ''"><p class="update-notice">Updated: <xsl:value-of select="$revised"/></p></xsl:if>
<hr/>
 </xsl:template>

    <xsl:template match="hdwd">
<p class="dealt-hdwd">
    <xsl:value-of select="."/>
</p>
    </xsl:template>

   <xsl:template match="pron_list">
      <span onclick="toggle('readings');return false;" style="font-family:'Calibri'">[<a href="#"><xsl:value-of select="$rdglabel"/></a>]</span>   
      <div id="readings" style="display: none;">
   <xsl:for-each select="pron">
<xsl:if test="@system">
[<xsl:value-of select="@lang"/>-<xsl:value-of select="@system"/>]
</xsl:if>
<xsl:if test="@read">
[<xsl:value-of select="@read"/>]
</xsl:if>
<xsl:value-of select="."/>
    <xsl:if test="@initial">
      (initial = <xsl:value-of select="@initial"/>)
     </xsl:if>
<br/>

	</xsl:for-each></div>
    </xsl:template>

   <xsl:template match="sense_area">
<p class="dealt-meanings-label">Meanings</p>
    <xsl:apply-templates/><hr/>
    </xsl:template>
  
<xsl:template match="sense_group">
<!-- MB 2001-01-19
*    Moved the apply-templates from here (where it
*    just causes the first sense to appear twice) to
*    inside the for-each loop (where we need it otherwise
*    xrefs won't be handled) This is rather awkward and
*    might be avoided by re-thinking the markup of the main
*    files a little

-->
 <xsl:for-each select="sense">
   <xsl:variable name="origin" select="@orig"/>
<!--
-->
   <li> <xsl:if test="@orig">[<xsl:value-of select="$origin"/>]<xsl:text> </xsl:text></xsl:if><xsl:apply-templates/> <xsl:variable name="reference" select="@source"/>
     <xsl:variable name="responsible" select="@resp"/>
       <xsl:text> </xsl:text><xsl:if test="@source">[source(s): <xsl:value-of select="@source"/>]</xsl:if><xsl:if test="string-length(.) &gt; 100">(<xsl:value-of select="@resp"/>)</xsl:if></li>

<!-- see above comment for why next is here
   <xsl:apply-templates select ="xref"/></li>
-->
 
</xsl:for-each>

  <!-- CM 2019-06-29 Endnote placer -->
  <xsl:if test="//note[@place='end']">
    <hr/>
    <p class="ddb-notes-label">Notes</p>
    <xsl:for-each select="//note[@place='end']">
      <xsl:apply-templates  select="."  mode="shownotes"/>
    </xsl:for-each>
    <hr/>
  </xsl:if>
  

<!-- CM 2011-01-21 Comments form begins Moved to here MB 2017-10-31 -->
<br/> <span onclick="toggle('comments');return false;"><a href="#"><xsl:value-of select="$commentslabel"/></a></span>
     <div id="comments" style="display: none;">
    <form action="/cgi-bin/cjkve-comments" name="CJKV-E User Comment">
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
  

 <xsl:template match="compounds">
      <p class="dealt-compounds-label">[Other words containing this character] </p>
    <xsl:apply-templates/>
</xsl:template>

 <xsl:template match="dictref[/*]"><p class="dealt-dictref-label">[Dictionary References] </p>
    <xsl:apply-templates/>
    </xsl:template>

<xsl:template match="dict"><p style="margin-top:0.2em; margin-bottom:0">
<xsl:text> </xsl:text><xsl:apply-templates/></p>
    </xsl:template>

<xsl:template match="page"><xsl:text> </xsl:text><xsl:apply-templates/></xsl:template>


<!-- MB There would be slightly better ways of achieving
*    what this does...
-->

<xsl:template match="foreign"><span style="font-style:italic"><xsl:apply-templates/></span> </xsl:template>



<!-- MB 2001-01-19
*  Display the radical
*  For this to be useful, the radicals will need to be
*  assigned ids so that they can be xrefed as in your
*  html version. 
-->  
<xsl:template match="radical">
  <p style="font-size:large">radical <xsl:value-of select="@glyph"/></p> 
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

<!-- First handle a dealt-internal reference, if that's
*    what we have
-->

<xsl:choose>


<xsl:when  test="@idref and not(@active ='no')">


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

<xsl:if test = "$dictcode = 'b'">Also in: </xsl:if>

<xsl:call-template  name = "writelink">  
  <xsl:with-param  name = "linktext">
 <xsl:value-of select="."/> 
  </xsl:with-param>
  <xsl:with-param name="target">
  <xsl:choose>
  <xsl:when test = "$dictcode = 'c'">
  <xsl:value-of select="concat($cgipref,$hibyte,'.xml',$xpathpref,$thisref,$xpathsuf)"/> 
  </xsl:when>
 <xsl:when test = "$dictcode = 'b'">
 <xsl:value-of select="concat($ddb-cgipref,$hibyte,'.xml',$xpathpref,$thisref,$xpathsuf)"/>
 </xsl:when>
 </xsl:choose>
  </xsl:with-param>	
</xsl:call-template>

</xsl:when>

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

<xsl:template match = "a">
<br/>

<xsl:call-template  name = "writelink">  
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

	<a style="text-decoration: none"><xsl:attribute name="href"><xsl:value-of select="$target"/>
	</xsl:attribute>
	<xsl:value-of select="$linktext"/></a>
</xsl:template>

<!-- MB 2001-02-15
*    Callable template to write a hyperlink with a _blank target
*    Params are $target and $linktext
*    This version sets a _blank target
-->

<xsl:template name="writelink2">
<xsl:param name="target"/>
<xsl:param name="linktext"/>

	<a style="text-decoration: none"><xsl:attribute name="href"><xsl:value-of select="$target"/>
	</xsl:attribute><xsl:attribute name="target"><xsl:value-of select="'_blank'"/></xsl:attribute>
	<xsl:value-of select="$linktext"/>	</a>
</xsl:template>

<!-- MB 2001-01-25
*  Write this heading only if there are entries to follow
-->



<!-- CM 2003-06-18
*  List handler to render lists to numbered, bulleted
* and plain ("simple").
-->

 <xsl:template match="list">
     <xsl:choose>
<xsl:when test="@type='bulleted'">
 <ul style="list-style-type: discs">
<xsl:for-each select="item">
<li><xsl:apply-templates/></li>
</xsl:for-each>
</ul>
</xsl:when>
<xsl:when test="@type='ordered'">
  <ul style="list-style-type: decimal">
<xsl:for-each select="item">
<li><xsl:apply-templates/></li>
</xsl:for-each>
</ul>
</xsl:when>
<xsl:when test="@type='simple'">
 <ul style="list-style-type: none">
<xsl:for-each select="item">
<li><xsl:apply-templates/></li>
</xsl:for-each>
</ul>
  </xsl:when>
<xsl:otherwise>
  <ul style="list-style-type: discs">
<xsl:for-each select="item">
<li><xsl:apply-templates/></li>
</xsl:for-each>
</ul>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

  <xsl:template match="bibl">
   <xsl:choose>
     <xsl:when test="@type='canonref'">
       <xsl:choose>
         <xsl:when test="@corresp">
           〔<xsl:apply-templates/>
           <xsl:variable name="ctextfirst">http://ctext.org/</xsl:variable>
           <xsl:variable name="ctextend">?searchu=</xsl:variable>
           <a style="font-size:80%; font-weight:bold; text-decoration:none"><xsl:attribute name="href"><xsl:value-of select="$ctextfirst"/><xsl:value-of select="@corresp"/><xsl:value-of select="$ctextend"/><xsl:value-of select="ancestor::entry/hdwd"/></xsl:attribute> [ctext]</a>〕           
         </xsl:when>
         <xsl:otherwise> 
           〔<xsl:apply-templates/>〕
         </xsl:otherwise>
       </xsl:choose>
  
     </xsl:when>
     <xsl:otherwise>
  <p style="text-indent:-10mm;margin-left:10mm; margin-top: 0; margin-bottom: 0">
      <xsl:apply-templates/>
    </p>      
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
        <p style="margin-left:10mm; margin-top:1em; margin-bottom:1em; text-indent:0mm; margin-right:2mm">
          <xsl:apply-templates/>
        </p>
      </xsl:when>
      <xsl:when test="@rend='head1'">
        <p style="text-align:center; font-weight:bold; margin-top:1em; margin-bottom:1em; text-indent:0mm; font-decoration: underline">
          <xsl:apply-templates/>
        </p>
      </xsl:when> 
      <xsl:when test="@rend='head2'">
        <p style="margin-top:1em; margin-bottom:1em; text-indent:0mm; margin-right:2mm;font-decoration: underline">
          <xsl:apply-templates/>
        </p>
      </xsl:when>  
      <xsl:when test="@rend='head-bold'">
        <p style="margin-top:1em; margin-bottom:1em; text-indent:0mm; margin-right:2mm;font-weight: bold">
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
  
 <xsl:template match="quote[@rend='brackets']">
    <span style="font-family: MingLiU, Simsun, Mincho">「<xsl:apply-templates/>」</span>
  </xsl:template>

  <xsl:template match="quote[@rend='bq']">
        <p style="margin-left:10mm; margin-top:1em; margin-bottom:1em; text-indent:0mm; margin-right:2mm">
          <xsl:apply-templates/>
        </p>
  </xsl:template>
  
  <xsl:template match="quote[@rend='dq']">
    &quot;<xsl:apply-templates/>&quot;
  </xsl:template>
  <xsl:template match="quote[@rend='sq']">
    &apos;<xsl:apply-templates/>&apos;
  </xsl:template>
  <xsl:template match="soCalled">
    &quot;<xsl:apply-templates/>&quot;
  </xsl:template>

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
  
  <xsl:template match="term">
    <xsl:choose>
      <xsl:when test="@xml:lang='en' or @lang='en'">
   <xsl:apply-templates/>       
      </xsl:when>
      <xsl:when test="@rend='q'">&quot;<xsl:apply-templates/>&quot;</xsl:when>
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
        <span style="font-decoration:underline"><xsl:apply-templates/></span>       </xsl:when>
      <xsl:otherwise>
        <span style="font-weight:bold"><xsl:apply-templates/></span>       
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!--   <xsl:include href="biblStruct.xsl"/>-->
  
  <xsl:template match="title">
    <xsl:choose>
      <xsl:when test="ancestor::listBibl">
        <xsl:choose>
          <xsl:when
            test="@level='m' or @level='j' or @level='s' or parent::monogr">
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
              <xsl:when test="parent::gloss[@xml:lang='en'] or parent::gloss[@lang='en']">
                <span style="font-style:italic">
                  <xsl:apply-templates/>
                </span>
              </xsl:when>
              <xsl:when test="following-sibling::imprint/biblScope[@type='vol']">
                <span style="font-style:italic">
                  <xsl:apply-templates/>
                </span>
                <xsl:text> </xsl:text>
              </xsl:when>
              <xsl:when test="preceding-sibling::title[@level='a']"><xsl:text>In </xsl:text><span style="font-style:italic"><xsl:apply-templates/>. </span>
              </xsl:when>
              <xsl:otherwise>
                <span style="font-style:italic"><xsl:apply-templates/>. </span>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="@type='parallel'">(<xsl:apply-templates/>) </xsl:when>
          <xsl:when
            test="@level='a' or @level='u' or parent::analytic or ancestor::biblStruct[@type='thesis']">
            <xsl:choose>
              <xsl:when test="child::gloss[@xml:lang='en'] or child::gloss[@lang='en']"> &#x201c;<xsl:apply-templates/>
              </xsl:when>
              <xsl:when test="substring(., string-length(.)) = '.'">
                &#x201c;<xsl:apply-templates/>&#x201d;</xsl:when>
              <xsl:when test="substring(., string-length(.)) = '?'">
                &#x201c;<xsl:apply-templates/>&#x201d;</xsl:when>
              <xsl:when test="substring(., string-length(.)) = ','">
                &#x201c;<xsl:apply-templates/>&#x201d;</xsl:when>
              <xsl:otherwise> &#x201c;<xsl:apply-templates/>.&#x201d;&#160;</xsl:otherwise>
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
  
  <xsl:template match="gloss">
    <xsl:choose>
      <xsl:when test="parent::title">
        <xsl:choose>
          <xsl:when test="@lang='sa' or @xml:lang='sa' ">
            <span style="font-style:italic"> (<xsl:apply-templates/>)</span>
          </xsl:when>
          <xsl:when test="@xml:lang='ja'">
            <span style="font-style:normal; font-family: 'ＭＳ Ｐ明朝', 'MS PMincho', 'ヒラギノ明朝 Pro W3', 'メイリオ', Meiryo, serif"><xsl:text> </xsl:text>
              <xsl:apply-templates/></span>
          </xsl:when>
          <xsl:when test="@xml:lang='zh'">
            <span style="font-style:normal; font-family: 'ＭＳ Ｐ明朝', 'MS PMincho', Tahoma, Arial, Helvetica, Yahei, '微软雅黑', 宋体, SimSun, STXihei, '华文细黑', sans-serif; serif"><xsl:text> </xsl:text>
              <xsl:apply-templates/></span>
          </xsl:when>
          <xsl:otherwise>
            <span style="font-style:normal"> (<xsl:apply-templates/>)</span>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
    
 <!-- Bibliographical renderings -->
<xsl:template match="listBibl">
  <xsl:choose>
    <xsl:when test="@rend='classics'">
      <xsl:for-each select="biblStruct">
        <xsl:sort select="descendant::title[1]"/>       
        <p style="text-indent:-10mm;margin-left:10mm">
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
          <p style="text-indent:-10mm;margin-left:10mm; font-size:11pt">
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
        <p style="text-indent:-10mm;margin-left:10mm; line-height: 200%">
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
      <xsl:if test="child::title[@level='m'] or child::title[@level='u']">
      <xsl:apply-templates select="imprint/date"/>
      </xsl:if>
    <xsl:apply-templates select="title"/>
    <xsl:apply-templates select="imprint/pubPlace"/>
      <xsl:apply-templates select="imprint/publisher"/>
      <xsl:apply-templates select="imprint/biblScope"/>
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
                /><xsl:if test="child::gloss"><xsl:text>&#160;</xsl:text><xsl:value-of select="gloss"/></xsl:if><xsl:text>.&#160;</xsl:text>
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
                                  <xsl:value-of select="surname"/>, <xsl:value-of select="forename"
                                  /><xsl:text>, trans.&#160;</xsl:text>
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
                        <xsl:value-of select="surname"/>, <xsl:value-of select="forename"
                        /><xsl:text>, ed.&#160;</xsl:text>
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
        ><xsl:apply-templates/>&#160;</xsl:when>
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
       <xsl:when test="ancestor::monogr[1]/title[@level='j']"><xsl:apply-templates/>. </xsl:when>
       <xsl:when test="ancestor::monogr[1]/title[@level='m']"><xsl:apply-templates/>. </xsl:when>
       <xsl:otherwise>pp. <xsl:apply-templates/>. </xsl:otherwise>
      </xsl:choose>
     </xsl:when>
     <xsl:when test="@unit='canonref'">
      <xsl:apply-templates/>. </xsl:when>
      <xsl:when test="@unit='fascicles'">
        <xsl:apply-templates/>, </xsl:when>
     <xsl:when test="@unit='issue'"> (<xsl:apply-templates/>): </xsl:when>
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

