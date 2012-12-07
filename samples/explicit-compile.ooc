use llvm
import llvm/[Core, ExecutionEngine, Target]
import structs/ArrayList
import math

main: func {
    LLVMLinkInJIT()
    Target initializeNative()
    
    myModule := LModule new("exte")

    double_ := Type double_()

    // external interface for cos
    cos := myModule addFunction("cos", double_, [double_], ["x"])

    // our function
    sumcos := myModule addFunction("picos", double_, [double_], ["x"])
    builder := sumcos builder()

    {
        piVal := Value constReal(double_, PI)
        cosarg := builder fmul(piVal, sumcos args[0], "cosarg")
        result := builder call(cos, [cosarg], "result")
        builder ret(result)
    }

    // We've completed the definition now! Let's see the LLVM assembly
    // language representation of what we've created:
    myModule dump()

    // Now, to try to run the function!
    provider := ModuleProvider new(myModule)
    engine := ExecutionEngine new(provider)

    addr := engine recompileAndRelinkFunction(sumcos)
    f: Func (Double) -> Double = (addr, null) as Closure

    result := f(1.0 / 4.0)
    result toString() println()
}
