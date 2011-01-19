/**
 * Integration plugin for noscript extension
 *
 * Usage:
 *   :noscript info        Shows noscript info for the current page.
 *   :noscript popup       Opens the noscript popup.
 *   :noscript toggletemp  Toggles scripts temporarily on current page.
 *   :noscript toggleperm  Toggles scripts permanently on current page.
 *
 * Note: when the noscript popup is open, you can scroll through the items
 * using the following standard vimperator key bindings:
 *   j  move down one
 *   k  move up one
 *   l  open the sub-menu
 *   h  close the sub-menu
 *   g  jump to the first item in the menu
 *   G  jump to the last item in the menu
 * For implementation simplicity, only single character bindings are supported,
 * so you cannot supply counts to any of the above.
 *
 * Tested against NoScript 1.8.6
 *
 * @author Eric Van Dewoestine (ervandew@gmail.com)
 * @version 0.4
 *
 * First two versions written by Martin Stubenschrott, but now maintained by
 * Eric.  Please direct all correspondence regarding this plugin to Eric.
 */

/**
 * Class which provides support for noscript commands and hooks into the
 * noscript popup to provide vimperator scrolling bindings (j,k,l,h,g,G).
 *
 * Note: There appears to be a bug in firefox's menupopup key bindings, where
 * if you navigate to a sub popup (l or right arrow), and navigate back to the
 * main popup (h or left arrow), then the menupopup seems to lose the ability
 * to navigate back to the sub menu, and loses the ability to close the main
 * popup via esc (an alt-tab should still close it).  This behavior is
 * reproducable with or without this plugin.
 */
function NoscriptVimperator() {
  var popup = (
    noscriptOverlay.stickyUI &&
    noscriptOverlay.ns.getPref("stickyUI.onKeyboard") &&
    (popup = noscriptOverlay.stickyUI)
  ) || document.getElementById("noscript-status-popup");
  popup.addEventListener('popupshown', popupshown, true);
  popup.addEventListener('popuphidden', popuphidden, true);

  function popupshown(event){
    if (event.target == popup){
      window.addEventListener("keypress", keypress, true);
    }
  }

  function popuphidden(event){
    if (event.target == popup){
      window.removeEventListener("keypress", keypress, true);
    }
  }

  function keypress(event){
    var keyCode = null;
    switch(String.fromCharCode(event.which)){
      case "j":
        keyCode = 40;
        break;
      case "k":
        keyCode = 38;
        break;
      case "l":
        keyCode = 39;
        break;
      case "h":
        keyCode = 37;
        break;
      case "G":
        keyCode = 35;
        break;
      case "g":
        keyCode = 36;
        break;
      default:
        break;
    }

    if (keyCode){
      var newEvent = window.document.createEvent('KeyboardEvent');
      newEvent.initKeyEvent(
        "keypress", true, true, null, false, false, false, false, keyCode, 0);
      popup.dispatchEvent(newEvent);
    }
  }

  return {
    info: function(){
      liberator.echo(util.objectToString(noscriptOverlay.getSites(), true));
    },

    popup: function(){
      noscriptOverlay.showUI();
    },

    toggletemp: function(){
      noscriptOverlay.toggleCurrentPage(3);
    },

    toggleperm: function(){
      const ns = noscriptOverlay.ns;
      const url = ns.getQuickSite(content.document.documentURI, /*level*/ 3);
      noscriptOverlay.safeAllow(url, !ns.isJSEnabled(url), false);
    },

    _execute: function(args){
      var name = args.shift();
      var cmd = nsv[name];
      if (!cmd){
        liberator.echoerr('Unsupported noscript command: ' + name);
        return false;
      }
      return cmd(args);
    },

    _completer: function(context){
      var commands = [];
      for (var name in nsv){
        if (name.indexOf('_') !== 0 && nsv.hasOwnProperty(name)){
          commands.push(name);
        }
      }
      context.completions = [[c, ''] for each (c in commands)];
    }
  };
}

var nsv = NoscriptVimperator();

commands.addUserCommand(["nosc[ript]"],
  "Execute noscript commands",
  function(args) { nsv._execute(args); },
  { argCount: '1', completer: nsv._completer }
);
