# Made by Pollis (Compose > New Methods > Package and Publish) from method.toml: change the method, not this file.
using Test, CSV, Downloads, Tables, ArcFS

const DATA = joinpath(@__DIR__, "data")

"An input table: a file of the tests, or downloaded from its link into memory."
function input(source; delim = ',', columns = nothing, header = true, skipto = nothing, limit = nothing)
	bytes = startswith(source, r"https?://") ? take!(Downloads.download(source, IOBuffer())) : read(joinpath(DATA, source))
	named = columns === nothing && header
	header = columns !== nothing ? Symbol.(columns) : named ? 1 : false
	rows = (; skipto = something(skipto, named ? 2 : 1), limit)
	file = delim == "whitespace" ? CSV.File(bytes; header, rows..., delim = ' ', ignorerepeated = true, stripwhitespace = true) : CSV.File(bytes; header, rows..., delim = delim == "tab" ? '\t' : only(delim))
	return Tables.columntable(file)
end

"The published table: its row labels and its values as printed, `nothing` where a cell is empty."
function target(file)
	table = CSV.File(joinpath(DATA, "targets", file * ".csv"); types = String, delim = ',')
	columns = Tables.columnnames(table)
	rows = [string(coalesce(row[columns[1]], "")) for row in table]
	values = [let cell = row[column]; cell === missing ? nothing : strip(cell) end for row in table, column in columns[2:end]]
	return rows, string.(columns[2:end]), values
end

"Tests each printed value against the result rounded to the digits printed."
function check(result, file, tolerance)
	rows, columns, values = target(file)
	result = result isa AbstractVecOrMat ? result : Tables.matrix(result)
	result = reshape(result, size(result, 1), :)
	@test size(result) == size(values)
	for i in axes(values, 1), j in axes(values, 2)
		printed = values[i, j]
		(printed === nothing || isempty(printed)) && continue
		mantissa, exponent = occursin(r"[eE]", printed) ? split(printed, r"[eE]") : (printed, "0")
		digits = (occursin('.', mantissa) ? length(split(mantissa, '.')[2]) : 0) - parse(Int, exponent)
		published = parse(Float64, printed)
		computed = round(result[i, j]; digits)
		@testset "$(rows[i]), $(columns[j])" begin
			@test isapprox(computed, published; atol = (tolerance + 1e-6) * 10.0^-digits)
		end
	end
end

@testset "ArcFS" begin
	@testset "Breiman (2001), Table 2, p. 11: one run on the given test set" begin
		letters = input("https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/letters.csv")
		satimage = input("https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/satimage.csv")
		ziptest = input("https://hastie.su.domains/ElemStatLearn/datasets/zip.test.gz"; delim = "whitespace", columns = ["digit", "p1", "p2", "p3", "p4", "p5", "p6", "p7", "p8", "p9", "p10", "p11", "p12", "p13", "p14", "p15", "p16", "p17", "p18", "p19", "p20", "p21", "p22", "p23", "p24", "p25", "p26", "p27", "p28", "p29", "p30", "p31", "p32", "p33", "p34", "p35", "p36", "p37", "p38", "p39", "p40", "p41", "p42", "p43", "p44", "p45", "p46", "p47", "p48", "p49", "p50", "p51", "p52", "p53", "p54", "p55", "p56", "p57", "p58", "p59", "p60", "p61", "p62", "p63", "p64", "p65", "p66", "p67", "p68", "p69", "p70", "p71", "p72", "p73", "p74", "p75", "p76", "p77", "p78", "p79", "p80", "p81", "p82", "p83", "p84", "p85", "p86", "p87", "p88", "p89", "p90", "p91", "p92", "p93", "p94", "p95", "p96", "p97", "p98", "p99", "p100", "p101", "p102", "p103", "p104", "p105", "p106", "p107", "p108", "p109", "p110", "p111", "p112", "p113", "p114", "p115", "p116", "p117", "p118", "p119", "p120", "p121", "p122", "p123", "p124", "p125", "p126", "p127", "p128", "p129", "p130", "p131", "p132", "p133", "p134", "p135", "p136", "p137", "p138", "p139", "p140", "p141", "p142", "p143", "p144", "p145", "p146", "p147", "p148", "p149", "p150", "p151", "p152", "p153", "p154", "p155", "p156", "p157", "p158", "p159", "p160", "p161", "p162", "p163", "p164", "p165", "p166", "p167", "p168", "p169", "p170", "p171", "p172", "p173", "p174", "p175", "p176", "p177", "p178", "p179", "p180", "p181", "p182", "p183", "p184", "p185", "p186", "p187", "p188", "p189", "p190", "p191", "p192", "p193", "p194", "p195", "p196", "p197", "p198", "p199", "p200", "p201", "p202", "p203", "p204", "p205", "p206", "p207", "p208", "p209", "p210", "p211", "p212", "p213", "p214", "p215", "p216", "p217", "p218", "p219", "p220", "p221", "p222", "p223", "p224", "p225", "p226", "p227", "p228", "p229", "p230", "p231", "p232", "p233", "p234", "p235", "p236", "p237", "p238", "p239", "p240", "p241", "p242", "p243", "p244", "p245", "p246", "p247", "p248", "p249", "p250", "p251", "p252", "p253", "p254", "p255", "p256"])
		ziptrain = input("https://hastie.su.domains/ElemStatLearn/datasets/zip.train.gz"; delim = "whitespace", columns = ["digit", "p1", "p2", "p3", "p4", "p5", "p6", "p7", "p8", "p9", "p10", "p11", "p12", "p13", "p14", "p15", "p16", "p17", "p18", "p19", "p20", "p21", "p22", "p23", "p24", "p25", "p26", "p27", "p28", "p29", "p30", "p31", "p32", "p33", "p34", "p35", "p36", "p37", "p38", "p39", "p40", "p41", "p42", "p43", "p44", "p45", "p46", "p47", "p48", "p49", "p50", "p51", "p52", "p53", "p54", "p55", "p56", "p57", "p58", "p59", "p60", "p61", "p62", "p63", "p64", "p65", "p66", "p67", "p68", "p69", "p70", "p71", "p72", "p73", "p74", "p75", "p76", "p77", "p78", "p79", "p80", "p81", "p82", "p83", "p84", "p85", "p86", "p87", "p88", "p89", "p90", "p91", "p92", "p93", "p94", "p95", "p96", "p97", "p98", "p99", "p100", "p101", "p102", "p103", "p104", "p105", "p106", "p107", "p108", "p109", "p110", "p111", "p112", "p113", "p114", "p115", "p116", "p117", "p118", "p119", "p120", "p121", "p122", "p123", "p124", "p125", "p126", "p127", "p128", "p129", "p130", "p131", "p132", "p133", "p134", "p135", "p136", "p137", "p138", "p139", "p140", "p141", "p142", "p143", "p144", "p145", "p146", "p147", "p148", "p149", "p150", "p151", "p152", "p153", "p154", "p155", "p156", "p157", "p158", "p159", "p160", "p161", "p162", "p163", "p164", "p165", "p166", "p167", "p168", "p169", "p170", "p171", "p172", "p173", "p174", "p175", "p176", "p177", "p178", "p179", "p180", "p181", "p182", "p183", "p184", "p185", "p186", "p187", "p188", "p189", "p190", "p191", "p192", "p193", "p194", "p195", "p196", "p197", "p198", "p199", "p200", "p201", "p202", "p203", "p204", "p205", "p206", "p207", "p208", "p209", "p210", "p211", "p212", "p213", "p214", "p215", "p216", "p217", "p218", "p219", "p220", "p221", "p222", "p223", "p224", "p225", "p226", "p227", "p228", "p229", "p230", "p231", "p232", "p233", "p234", "p235", "p236", "p237", "p238", "p239", "p240", "p241", "p242", "p243", "p244", "p245", "p246", "p247", "p248", "p249", "p250", "p251", "p252", "p253", "p254", "p255", "p256"])
		check(ArcFS.large(letters, satimage, ziptrain, ziptest), "large", 25)
	end
	@testset "Breiman (2001), Table 2, p. 11: 50 runs of 300 training and 3,000 test cases" begin
		check(ArcFS.simulated(), "simulated", 15)
	end
	@testset "Breiman (2001), Table 2, p. 11, and p. 15 (soybean): 100 runs of a 10% test set" begin
		breastwisconsin = input("https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/breastwisconsin.csv")
		ecoli = input("https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/ecoli.csv")
		germancredit = input("https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/germancredit.csv")
		glass = input("https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/glass.csv")
		image = input("https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/image.csv")
		ionosphere = input("https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/ionosphere.csv")
		liver = input("https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/liver.csv")
		pima = input("https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/pima.csv")
		sonar = input("https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/sonar.csv")
		soybean = input("https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/soybean.csv")
		vehicle = input("https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/vehicle.csv")
		votes = input("https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/votes.csv")
		vowel = input("https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/vowel.csv")
		check(ArcFS.small((; glass, breastwisconsin, pima, sonar, vowel, ionosphere, vehicle, soybean, germancredit, image, ecoli, votes, liver)), "small", 25)
	end
end
