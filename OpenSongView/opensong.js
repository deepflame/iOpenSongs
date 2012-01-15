(function($)
{
  // 
  $.fn.openSongLyrics = function(lyrics) {
    // clear Html Element
    $(this).html("");
  
    var lyricsLines = lyrics.split("\n");
  
    while(lyricsLines.length > 0) {
      var line = lyricsLines.shift();
    
      switch(line[0]) {
        case "[":
          var header = line;
          var number = "";
          
          // try to match default style
          var m = /\[(\w)(\d)?\]/g.exec(line);
          if (m) {
            header = replaceHeader(m[1]);
            number = m[2] ? m[2] : "";
          } else {
            // try to match 'custom style'
            m = /\[(\w*)\]/g.exec(line);
            header = m ? m[1] : line;
          }
          
          $(this).append("<h2>" + header + " " + number + "</h2>");
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
        
          var lyricsLine = lyricsLines.shift().substr(1);
        
          var lyricsArr = new Array();
          // split lyrics line based on chord length
          for (var i in chordArr) {
          
            if (i < chordArr.length - 1) {
              var chordLength = chordArr[i].length;          
              // split String with RegExp (is there a better way?)
              var m = lyricsLine.match(new RegExp("(.{"+ chordLength +"})(.*)"));
          
              if(m === null) {
                lyricsArr.push("");
              } else {
                lyricsArr.push(m[1]);
                lyricsLine = m[2];
              }
            } else {
              // add the whole string if at the end of the chord arr
              lyricsArr.push(lyricsLine);
            }
          }
        
          //console.log(chordArr);        
          //console.log(lyricsArr);
        
          var htmlTableRows = "<tr class='chords'><td>" + chordArr.join("</td><td>") + "</td></tr>\n";
          htmlTableRows = htmlTableRows + "<tr class='lyrics'><td>" + lyricsArr.join("</td><td>") + "</td></tr>\n";
        
          $(this).append("<table>" + htmlTableRows + "</table>");
          break;
        case " ":
          $(this).append("<div class='lyrics'>" + line.substr(1) + "</div>");
          break;
        case ";":
          $(this).append("<div class='comments'>" + line.substr(1) + "</div>");
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
          return "Chorus";
        case "V":
          return "Verse";
        case "B":
          return "Bridge";
        case "T":
          return "Tag";
        case "P":
          return "Pre-Chorus";
        case "I":
          return "Intro";
        case "O":
          return "Outro";
        }
    }
  }
})(jQuery);
