use llvm
import llvm/[Core, ExecutionEngine, Target]
import structs/ArrayList
import math

main: func {
    LLVMLinkInJIT()
    LTarget initializeNative()
    
    myModule := LModule new("exte")

    double_ := LType double_()

    // external interface for cos
    cos := myModule addFunction("cos", double_, [double_], ["x"])

    // our function
    sumcos := myModule addFunction("picos", double_, [double_], ["x"])
    builder := sumcos builder()

    {
        piVal := LValue constReal(double_, PI)
        cosarg := builder fmul(piVal, sumcos args[0], "cosarg")
        result := builder call(cos, [cosarg], "result")
        builder ret(result)
    }

    // We've completed the definition now! Let's see the LLVM assembly
    // language representation of what we've created:
    myModule dump()

    // Now, to try to run the function!
    provider := LModuleProvider new(myModule)
    engine := LExecutionEngine new(provider)

    addr := engine recompileAndRelinkFunction(sumcos)
    f: Func (Double) -> Double = (addr, null) as Closure

    result := f(1.0 / 4.0)
    result toString() println()
}
