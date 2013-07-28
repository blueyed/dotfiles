///* dtyuan: 5/9/2010
//  Freeware
//
//  credit: http://mark.koli.ch/2009/09/
//  @source: http://www.michaelapproved.com/articles/object-position-top-and-left-offset-on-a-page/
//*/
var INFO = 
<plugin name="center_select" version="1.0"
      href="http://code.google.com/p/vimperator-labs/issues/detail?id=221"
      summary="Auto-scroll selected/searched text to the center of the screen (zz)"
      xmlns="http://vimperator.org/namespaces/liberator">
    <author email="dty...@gmail.com">DTYUAN</author>
    <license href="http://www.gnu.org/licenses/licenses.html">GNU GPL</license>
    <project name="Vimperator" minVersion="2.0"/>
    <p>
      There is a need of "zz" to bring the selected text to the center of the
      screen, especially when moving to next search match at the bottom of
      screen.  It would be nice to keep the context of the search focus in view.
      
      This plugin provides the "zz" like functionality for selected/searched text.
    </p>
    <item>
      <tags>'center_select' 'zz'</tags>
      <spec>'center_select' 'zz'</spec>
            <type>boolean</type>
            <default>true</default>
      <description>
        <p>
          <![CDATA[
            "nnoremap <silent> zz :centerselect<CR>
            "nnoremap <silent> zz :centerselect "border: 5px solid orange;"<CR>
            "nnoremap <silent> n n:norm zz<CR>
            "nnoremap <silent> N N:norm zz<CR>
            "nnoremap <silent> zt :topselect<CR>
            "nnoremap <silent> zb :bottomselect<CR>
            "nnoremap <silent> zc :removeselect<CR>

            " new function to override search keys to show center box when typing selecting text
            javascript <<EOF
              Finder.prototype.openNewPrompt = function (mode) {
                  this._backwards = mode == modes.SEARCH_BACKWARD;
                  commandline.input(this._backwards ? "Find backwards" : "Find", this.closure.onSubmit, {
                      onChange: function() { 
                        if (options["incsearch"]){
                          finder.find(commandline.command);
                          plugins.center_select.CenterSelect.Selector.center();
                        }
                      }
                  });
              }
              mappings.addUserMap([modes.NORMAL, modes.CARET], ["/"], "Search forward for a pattern and center", function () { finder.openNewPrompt(modes.SEARCH_FORWARD);});
              mappings.addUserMap([modes.NORMAL, modes.CARET], ["?"], "Search backward for a pattern and center", function () { finder.openNewPrompt(modes.SEARCH_BACKWARD);});
            EOF

            " new/updated mappings
            nnoremap <silent> zz :javascript plugins.center_select.CenterSelect.Selector.center();<CR>
            nnoremap <silent> n :javascript finder.findAgain(false); plugins.center_select.CenterSelect.Selector.center();<CR>
            nnoremap <silent> N :javascript finder.findAgain(true); plugins.center_select.CenterSelect.Selector.center();<CR>
            nnoremap <silent> zt :javascript plugins.center_select.CenterSelect.Selector.top();<CR>
            nnoremap <silent> zb :javascript plugins.center_select.CenterSelect.Selector.bottom();<CR>
            nnoremap <silent> zc :javascript plugins.center_select.CenterSelect.Selector.remove();<CR>

            " optional mappings
            nnoremap zh 50h
            nnoremap zh 50l
            nnoremap j 20j
            nnoremap k 20k
            nnoremap l 20l
            nnoremap h 20h
          ]]>;
        </p>
      </description>
  </item>
</plugin>;


var CenterSelect;
CenterSelect = {}; 
CenterSelect.Selector = {};
// shortcut for commandline
CS = CenterSelect.Selector;

// @source: http://www.michaelapproved.com/articles/object-position-top-and-left-offset-on-a-page/
function ObjectPosition(obj) {
  var curleft = 0;
  var curtop = 0;
  if (obj.offsetParent) {
    do {
      curleft += obj.offsetLeft;
      curtop += obj.offsetTop;
    } while (obj = obj.offsetParent);
  }
  return [curleft,curtop];
}

var SELECTFOCUSSTYLE = "border: 3px solid red; padding: 2px; z-index: 100;";
var selectFocusStyle = "border: 3px solid red; padding: 2px; z-index: 100;";
var selectFocus;
function createSelectFocus(bodyObj)
{
  if(content.document.getElementById("selectFocus") == null)
  {
    selectFocus = content.document.createElement('div');
    selectFocus.setAttribute('id', 'selectFocus');
    selectFocus.setAttribute('style', 'position: absolute; top: 0px; left: -900px; width: 0px; height: 0px; '
        + selectFocusStyle);
    bodyObj.appendChild(selectFocus);
  }
  else
  {
    selectFocus = content.document.getElementById("selectFocus");
  }
}

var target_positions = {"top":0, "center":1, "bottom":2};

CenterSelect.Selector.getRect = function(element){
  return element.getRangeAt(0).getBoundingClientRect();
}

CenterSelect.Selector.animate = function(element, target_position){
  var visibleElement = CenterSelect.Selector.getVisibleElement(element);
  //alert(visibleElement.tagName);
  if (visibleElement && 
      (visibleElement.tagName.toLowerCase () == "textarea" || 
       visibleElement.tagName.toLowerCase () == "input")) 
  {
    visibleElement.blur();
    return;
  }
  var selectionElement = CenterSelect.Selector.getSelected();
  var selectRect = CenterSelect.Selector.getRect(selectionElement);

  var scrolltopDE = content.document.documentElement.scrollTop;
  var scrolltopBD = content.document.body.scrollTop;
  bodyObj = (scrolltopDE > 0 ? content.document.documentElement : content.document.body);
  createSelectFocus(bodyObj);

  target = content.pageYOffset;

  switch(target_position) {
    case target_positions.top:
      //target = bodyObj.scrollTop ;
      target = target + 20;
      break;
    case target_positions.center:
      //target = bodyObj.scrollTop + Math.floor(bodyObj.clientHeight/2 - visibleElement.clientHeight/2 );
      target = target + Math.floor(bodyObj.clientHeight/2 - selectRect.height/2 );
      break;
    case target_positions.bottom:
      //target = bodyObj.scrollTop + Math.floor(bodyObj.clientHeight - visibleElement.clientHeight - visibleElement.offsetHeight);
      target = target + Math.floor(bodyObj.clientHeight - selectRect.height) - 20;
      break;
  }

  //newOffset = ObjectPosition(visibleElement)[1] - target;
  newOffset = content.pageYOffset + selectRect.top - target;
  
  content.scrollTo(bodyObj.scrollLeft + selectRect.left - 20, bodyObj.scrollTop + newOffset);
  //content.scrollTo(0, bodyObj.scrollTop + newOffset);

  // refresh selectRect
  selectRect = CenterSelect.Selector.getRect(selectionElement);

  /*
  selectFocus.style.top = (ObjectPosition(visibleElement)[1] - selectFocus.style.borderTopWidth.replace("px", "")
      - selectFocus.style.paddingTop.replace("px", "")) + "px";
  selectFocus.style.left = (ObjectPosition(visibleElement)[0] - selectFocus.style.borderLeftWidth.replace("px", "")
      - selectFocus.style.paddingLeft.replace("px", "")) + "px";
  selectFocus.style.height = (visibleElement.offsetHeight *  1 + selectFocus.style.borderTopWidth.replace("px", "") *  1
      + selectFocus.style.paddingTop.replace("px", "") *  1) +"px";
  selectFocus.style.width = (visibleElement.offsetWidth * 1 + selectFocus.style.borderLeftWidth.replace("px", "") *  1
      + selectFocus.style.paddingLeft.replace("px", "") *  1) + "px";
  */

  selectFocus.style.top = (content.pageYOffset + selectRect.top - selectFocus.style.borderTopWidth.replace("px", "")
      - selectFocus.style.paddingTop.replace("px", "")) + "px";
  selectFocus.style.left = (content.pageXOffset + selectRect.left - selectFocus.style.borderLeftWidth.replace("px", "")
      - selectFocus.style.paddingLeft.replace("px", "")) + "px";
  selectFocus.style.height = (selectRect.height + selectFocus.style.borderTopWidth.replace("px", "") *  1
      + selectFocus.style.paddingTop.replace("px", "") *  1) +"px";
  selectFocus.style.width = (selectRect.width + selectFocus.style.borderLeftWidth.replace("px", "") *  1
      + selectFocus.style.paddingLeft.replace("px", "") *  1) + "px";

  if (content.document.activeElement && 
      (content.document.activeElement.tagName.toLowerCase () == "textarea" || 
       content.document.activeElement.tagName.toLowerCase () == "input")) 
  {
    content.document.activeElement.blur();
  }

};

CenterSelect.Selector.getVisibleElement = function(element){
  var field;

  try
  {
    //if (jQuery(element).attr("type") == 'hidden' || jQuery(element).is(':hidden')) 
    if (element.scrollWidth && element.scrollWidth ==0) 
    {
      field = element.prev();
    }
    else {
      field = element;
    }
  } catch(e) { //alert(e); 
  };

  return field;
};

CenterSelect.Selector.getSelected = function(){
  var t = '';
  if(content.window.getSelection){
    t = content.window.getSelection();
  }else 
    if(window.getSelection){
      t = window.getSelection();
    }else 
      if(content.document.getSelection){
        t = content.document.getSelection();
      }else if(content.document.selection){
        t = content.document.selection.createRange().text;
      }
    return t;
};

CenterSelect.Selector.mouseup = function(){
  var st = CenterSelect.Selector.getSelected();
  if(st!=''){
    alert("You selected:\n"+st);
  }
};

CenterSelect.Selector.center = function(mystyle){
  if(mystyle && mystyle!="") selectFocusStyle = mystyle;
    else selectFocusStyle = SELECTFOCUSSTYLE;

  try
  {
    var st = CenterSelect.Selector.getSelected();
    if(st!=''){
      obj = st.anchorNode.parentNode;
      //obj = jQuery(st.anchorNode).parent();
      CenterSelect.Selector.animate(obj, target_positions.center);
      //CenterSelect.Selector.animate(jQuery(st).parent()); 
    }
  } catch(e) { //alert(e); 
  };
};
CenterSelect.Selector.top = function(mystyle){
  if(mystyle && mystyle!="") selectFocusStyle = mystyle;
    else selectFocusStyle = SELECTFOCUSSTYLE;

  try {
    var st = CenterSelect.Selector.getSelected();
    if(st!=''){
      obj = st.anchorNode.parentNode;
      CenterSelect.Selector.animate(obj, target_positions.top);
    }
  } catch(e) { };
};
CenterSelect.Selector.bottom = function(mystyle){
  if(mystyle && mystyle!="") selectFocusStyle = mystyle;
    else selectFocusStyle = SELECTFOCUSSTYLE;

  try {
    var st = CenterSelect.Selector.getSelected();
    if(st!=''){
      obj = st.anchorNode.parentNode;
      CenterSelect.Selector.animate(obj, target_positions.bottom);
    }
  } catch(e) { };
};
CenterSelect.Selector.remove = function(){
  // var sf = content.document.getElementById("selectFocus");
  if( selectFocus ) {
    selectFocus.parentNode.removeChild(selectFocus);
  }
}

// cannot use "_" in the command name; that is, center_select will not work
commands.add(['centerselect'],
    'run centerselect from within vimperator.',
    function(mystyle) {
      CenterSelect.Selector.center(mystyle);
    }
);
commands.add(['topselect'],
    'run topselect from within vimperator.',
    function(mystyle) {
      CenterSelect.Selector.top(mystyle);
    }
);
commands.add(['bottomselect'],
    'run topselect from within vimperator.',
    function(mystyle) {
      CenterSelect.Selector.bottom(mystyle);
    }
);
commands.add(['removeselect'],
    'run removeselect from within vimperator.',
    function() {
      CenterSelect.Selector.remove();
    }
);

