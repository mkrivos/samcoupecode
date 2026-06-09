// Ghidra headless post-script: decompile a loaded Z80 blob to pseudo-C.
//
// Complementary aid only — the canonical deliverable stays the byte-exact
// z80dasm/z80asm .asm. Ghidra's Z80 module is community-grade: it does NOT model
// the shadow registers (EXX/EX AF,AF') or self-modifying code, and ROM calls
// (&00xx) appear as unresolved func_0xXXXX (the ROM image is not loaded). Use the
// output to understand control/data flow quickly, then hand-verify in the .asm.
//
// Args: <outPath.c> [entryHex ...]
//   Always disassembles from the image base; extra entry addresses are seeded
//   and turned into functions so they get decompiled.
//
// Invoked via the Makefile 'ghidra' target.

import ghidra.app.script.GhidraScript;
import ghidra.app.decompiler.*;
import ghidra.program.model.listing.*;
import ghidra.program.model.address.*;
import java.io.*;

public class ghidra_decompile extends GhidraScript {
    @Override
    public void run() throws Exception {
        String[] args = getScriptArgs();
        String outPath = (args.length >= 1) ? args[0]
                       : currentProgram.getExecutablePath() + ".ghidra.c";

        // Seed disassembly from the image base + any explicit entry addresses,
        // then let auto-analysis follow the call graph and create functions.
        Address base = currentProgram.getMinAddress();
        try { disassemble(base); } catch (Exception ex) {}
        try { if (getFunctionAt(base) == null) createFunction(base, null); } catch (Exception ex) {}
        for (int i = 1; i < args.length; i++) {
            Address a = toAddr(Long.parseLong(args[i].replace("0x", ""), 16));
            try { disassemble(a); } catch (Exception ex) {}
            try { if (getFunctionAt(a) == null) createFunction(a, null); } catch (Exception ex) {}
        }
        try { analyzeAll(currentProgram); } catch (Exception ex) {}

        DecompInterface di = new DecompInterface();
        di.openProgram(currentProgram);
        PrintWriter out = new PrintWriter(new FileWriter(outPath));
        out.println("// Ghidra " + getGhidraVersion() + " decompilation of "
                    + currentProgram.getName() + " (Z80). Reference aid only.");
        FunctionIterator fns = currentProgram.getFunctionManager().getFunctions(true);
        int n = 0;
        while (fns.hasNext()) {
            Function f = fns.next();
            DecompileResults r = di.decompileFunction(f, 60, monitor);
            if (r != null && r.decompileCompleted()) {
                out.println("// ===== " + f.getName() + " @ " + f.getEntryPoint() + " =====");
                out.println(r.getDecompiledFunction().getC());
                n++;
            }
        }
        out.println("// functions decompiled: " + n);
        out.close();
        println("ghidra_decompile wrote " + n + " functions to " + outPath);
    }
}
