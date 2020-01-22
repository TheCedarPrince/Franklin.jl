const td = mktempdir()
flush_td() = (isdir(td) && rm(td; recursive=true); mkdir(td))
J.FOLDER_PATH[] = td

fd2html_td(e)  = fd2html(e; dir=td)
fd2html_tdv(e) = J.fd2html_v(e; dir=td)

J.def_GLOBAL_PAGE_VARS!()
J.def_GLOBAL_LXDEFS!()

@testset "Paths" begin
    P = J.set_paths!()

    @test J.PATHS[:folder]   == td
    @test J.PATHS[:src]      == joinpath(td, "src")
    @test J.PATHS[:src_css]  == joinpath(td, "src", "_css")
    @test J.PATHS[:src_html] == joinpath(td, "src", "_html_parts")
    @test J.PATHS[:libs]     == joinpath(td, "libs")
    @test J.PATHS[:pub]      == joinpath(td, "pub")
    @test J.PATHS[:css]      == joinpath(td, "css")

    @test P == J.PATHS

    mkdir(J.PATHS[:src])
    mkdir(J.PATHS[:src_pages])
    mkdir(J.PATHS[:libs])
    mkdir(J.PATHS[:src_css])
    mkdir(J.PATHS[:src_html])
    mkdir(J.PATHS[:assets])
end

# copying _libs/katex in the J.PATHS[:libs] so that it can be used in testing
# the js_prerender_math
cp(joinpath(dirname(dirname(pathof(Franklin))), "test", "_libs", "katex"), joinpath(J.PATHS[:libs], "katex"))

@testset "Set vars" begin
    d = J.PageVars(
    	"a" => 0.5 => (Real,),
    	"b" => "hello" => (String, Nothing))
    J.set_vars!(d, ["a"=>"5", "b"=>"nothing"])

    @test d["a"].first == 5
    @test d["b"].first === nothing

    @test_logs (:warn, "Doc var 'a' (type(s): (Real,)) can't be set to value 'blah' (type: String). Assignment ignored.") J.set_vars!(d, ["a"=>"\"blah\""])
    @test_logs (:error, "I got an error (of type 'DomainError') trying to evaluate '__tmp__ = sqrt(-1)', fix the assignment.") J.set_vars!(d, ["a"=> "sqrt(-1)"])

    # assigning new variables

    J.set_vars!(d, ["blah"=>"1"])
    @test d["blah"].first == 1
end


@testset "Def+coms" begin # see #78
    st = raw"""
        @def title = "blah" <!-- comment -->
        @def hasmath = false
        etc
        """
    (m, fdv) = J.convert_md(st)
    @test fdv["title"].first == "blah"
    @test fdv["hasmath"].first == false
end