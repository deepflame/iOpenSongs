/*
 *  Project: opensong.js
 *  Description: displays OpenSong files nicely on a web page
 *  Author: Andreas Boehrnsen
 *  License: LGPL 2.1
 */

// the semi-colon before function invocation is a safety net against concatenated 
// scripts and/or other plugins which may not be closed properly.
;(function($)
{
  // jQuery wrapper around openSongLyrics function
  $.fn.openSongLyrics = function(lyrics) {
    try {
      openSongLyrics(this, lyrics);
    } catch(e) {
      alert(e);
    }
  }
  
  // displays Opensong 
  function openSongLyrics(domElem, lyrics) {
    // clear Html Element and add opensong class
    $(domElem).html("").addClass("opensong");
  
    var lyricsLines = lyrics.split("\n");
  
    while(lyricsLines.length > 0) {
      var line = lyricsLines.shift();
    
      switch(line[0]) {
        case "[":
          var header = line.match(/\[(.*)\]/)[1]
          // replace first char (e.g. V -> Verse)
          header = header.replace(header[0], replaceHeader(header[0]));
          
          $(domElem).append("<h2>" + header + "</h2>");
          break
        case ".":
          var chordsLine = line.substr(1);
        
          var chordArr = new Array();
          // split cords
          while (chordsLine.length > 0) {
            var m = /^(\S*\s*)(.*)$/.exec(chordsLine);
            chordArr.push(m[1]);
            chordsLine = m[2];
          }
          // add an item if it is an empty line
          if (chordArr.length == 0) {
            chordArr.push(chordsLine);            
          }
        
          // write html table row for the chords
          var htmlTableRows = "<tr class='chords'><td></td><td>" + chordArr.join("</td><td>") + "</td></tr>\n";
        
          var textLine = "", m = null, cleanRegExp = /_|\||---|-!!/g;
                    
          // while we have lines that match a textLine create an html table row
          while ((textLine = lyricsLines.shift()) && (m = textLine.match(/^([ 1-9])(.*)/))) {
            var textArr = new Array();
            var textLineNr = m[1];
            textLine = m[2];
            
            // split lyrics line based on chord length
            for (var i in chordArr) {
              if (i < chordArr.length - 1) {
                var chordLength = chordArr[i].length;          
                // split String with RegExp (is there a better way?)
                var m = textLine.match(new RegExp("(.{0,"+ chordLength +"})(.*)"));

                textArr.push(m[1].replace(cleanRegExp, ""));
                textLine = m[2];
              } else {
                // add the whole string if at the end of the chord arr
                textArr.push(textLine.replace(cleanRegExp, ""));
              }
            }
            // write html table row for the text (lyrics)
            htmlTableRows = htmlTableRows + "<tr class='lyrics'><td>" + textLineNr + "</td><td>" + textArr.join("</td><td>") + "</td></tr>\n";
          }
          // attach the line again in front (we cut it off in the while loop)
          if(textLine !== undefined) lyricsLines.unshift(textLine);
        
          $(domElem).append("<table>" + htmlTableRows + "</table>");
          break;
        case " ":
          $(domElem).append("<div class='lyrics'>" + line.substr(1) + "</div>");
          break;
        case ";":
          $(domElem).append("<div class='comments'>" + line.substr(1) + "</div>");
          break;
        default:
          var error_text = "no support for :" + line;
          //alert(error_text);
          console.log(error_text);
      };
    }

    function replaceHeader(abbr) {
      switch(abbr) {
        case "C":
          return "Chorus ";
        case "V":
          return "Verse ";
        case "B":
          return "Bridge ";
        case "T":
          return "Tag ";
        case "P":
          return "Pre-Chorus ";
        default:
          return abbr;
        }
    }
  }
})(jQuery);
