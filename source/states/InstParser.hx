// THIS CODE HAS BEEN PARTIALLY TAKEN FROM: https://community.haxe.org/t/is-there-a-way-to-read-arbitrary-haxe-code-into-a-file-using-macros/496/3
package states;
import haxe.macro.Context;

class ParseInst {
    macro static public function insertCode(code:String) {
        return Context.parse(code, Context.currentPos());
    }
}

