using StringDistances, Unicode, Test, Random

@testset "Distances" begin
	@testset "Hamming" begin
		@test Hamming()("martha", "marhta") ≈  2
		@test Hamming()("es an ", " vs an") ≈ 6
		@test Hamming()([1, 2, 3], [1,2, 4]) ≈ 1
		@inferred Hamming()("", "")
		@test ismissing(Hamming()("", missing))
	end

	@testset "Jaro" begin
		@test Jaro()("martha", "marhta") ≈  0.05555555555555547
		@test Jaro()("es an ", " vs an") ≈ 0.2777777777777777
		@test Jaro()(" vs an", "es an ") ≈ 0.2777777777777777
		@test Jaro()([1, 2, 3], [1,2, 4]) ≈ 0.2222222222222222
		@test Jaro()(graphemes("alborgów"), graphemes("amoniak")) == Jaro()("alborgów", "amoniak")
		@test Jaro()(" vs an", "es an ") ≈ 0.2777777777777777
		@test result_type(Jaro(), "hello", "world") == typeof(float(1))
		@inferred Jaro()("", "")
		@test ismissing(Jaro()("", missing))
	end

	@testset "Levenshtein" begin
		@test Levenshtein()("", "") == 0
		@test Levenshtein()("abc", "") == 3
		@test Levenshtein()("", "abc") == 3
		@test Levenshtein()("bc", "abc") == 1
		@test Levenshtein()("kitten", "sitting") == 3
		@test Levenshtein()("saturday", "sunday") == 3
		@test Levenshtein()("hi, my name is", "my name is") == 4
		@test Levenshtein()("a cat", "an act") == 3
		@test Levenshtein()("alborgów", "amoniak") == 6
		prefix = "my_prefix"
		@test Levenshtein()(prefix * "alborgów", prefix * "amoniak") == Levenshtein()("alborgów", "amoniak")
		@test Levenshtein()([1, 2, 3], [1, 2, 4]) == 1
		@test Levenshtein()(graphemes("alborgów"), graphemes("amoniak")) == Levenshtein()("alborgów", "amoniak")
		@test Levenshtein()("", "abc") == 3
		@test result_type(Levenshtein(), "hello", "world") == Int
		@inferred Levenshtein()("", "")
		@test ismissing(Levenshtein()("", missing))
	end

	@testset "OptimalStringAlignement" begin
		@test OptimalStringAlignement()("", "") == 0
		@test OptimalStringAlignement()("abc", "") == 3
		@test OptimalStringAlignement()("bc", "abc") == 1
		@test OptimalStringAlignement()("fuor", "four") == 1
		@test OptimalStringAlignement()("abcd", "acb") == 2
		@test OptimalStringAlignement()("cape sand recycling ", "edith ann graham") == 17
		@test OptimalStringAlignement()("jellyifhs", "jellyfish") == 2
		@test OptimalStringAlignement()("ifhs", "fish") == 2
		@test OptimalStringAlignement()("a cat", "an act") == 2
		@test OptimalStringAlignement()("a cat", "an abct") == 4
		@test OptimalStringAlignement()("a cat", "a tc") == 3
		@test OptimalStringAlignement()("abcdef", "abcxyf") == 2
		@test OptimalStringAlignement()("abcdef", "abcxyf"; max_dist = 2) == 2
		prefix = "my_prefix"
		@test OptimalStringAlignement()(prefix * "alborgów", prefix * "amoniak") == OptimalStringAlignement()("alborgów", "amoniak")
		@test OptimalStringAlignement()([1, 2, 3], [1,2, 4]) == 1
		@test OptimalStringAlignement()(graphemes("alborgów"), graphemes("amoniak")) == OptimalStringAlignement()("alborgów", "amoniak")
		@test OptimalStringAlignement()("bc", "abc") == 1
		@test result_type(OptimalStringAlignement(), "hello", "world") == Int
		@inferred OptimalStringAlignement()("", "")
		@test ismissing(OptimalStringAlignement()("", missing))
	end

	@testset "DamerauLevenshtein" begin
		@test DamerauLevenshtein()("", "") == 0
		@test DamerauLevenshtein()("CA", "ABC") == 2
		@test DamerauLevenshtein()("ABCDEF", "ABDCEF") == 1
		@test DamerauLevenshtein()("ABCDEF", "BACDFE") == 2
		@test DamerauLevenshtein()("ABCDEF", "ABCDE") == 1
		@test DamerauLevenshtein()("a cat", "an act") == 2
		@test DamerauLevenshtein()("a cat", "an abct") == 3
		@test DamerauLevenshtein()("a cat", "a tc") == 2
		prefix = "my_prefix"
		@test DamerauLevenshtein()(prefix * "alborgów", prefix * "amoniak") == DamerauLevenshtein()("alborgów", "amoniak")
		@test result_type(DamerauLevenshtein(), "hello", "world") == Int
		@inferred DamerauLevenshtein()("", "")
		@test ismissing(DamerauLevenshtein()("", missing))
	end

	@testset "RatcliffObershelp" begin
		@test RatcliffObershelp()("dixon", "dicksonx") ≈ 1 - 0.6153846153846154
		@test RatcliffObershelp()("alexandre", "aleksander") ≈ 1 - 0.7368421052631579
		@test RatcliffObershelp()("pennsylvania",  "pencilvaneya") ≈ 1 - 0.6666666666666
		@test RatcliffObershelp()("",  "pencilvaneya") ≈ 1.0
		@test RatcliffObershelp()("NEW YORK METS", "NEW YORK MEATS") ≈ 1 -  0.962962962963
		@test RatcliffObershelp()("Yankees",  "New York Yankees") ≈ 0.3913043478260869
		@test RatcliffObershelp()("New York Mets",  "New York Yankees") ≈ 0.24137931034482762
		@test RatcliffObershelp()([1, 2, 3], [1,2, 4]) ≈ 1/3
		@test RatcliffObershelp()(graphemes("alborgów"), graphemes("amoniak")) == RatcliffObershelp()("alborgów", "amoniak")
		@test RatcliffObershelp()("pennsylvania",  "pencilvaneya") ≈ 1 - 0.6666666666666
		@test result_type(RatcliffObershelp(), "hello", "world") == typeof(float(1))
		@inferred RatcliffObershelp()("", "")
		@test ismissing(RatcliffObershelp()("", missing))
	end

	@testset "QGram" begin
		@test QGram(1)("abc", "abc") == 0
		@test QGram(1)("", "abc") == 3
		@test QGram(1)("abc", "cba") == 0
		@test QGram(1)("abc", "ccc") == 4
		@test QGram(4)("aü☃", "aüaüafs") == 4
		@test QGram(2)(SubString("aü☃", 1, 4), SubString("aüaüafs", 1, 4)) == 2
		@test QGram(2)(graphemes("alborgów"), graphemes("amoniak")) ≈ QGram(2)("alborgów", "amoniak")
		@test QGram(1)("abc", "cba") == 0
		@test result_type(QGram(1), "hello", "world") == Int
		@test ismissing(QGram(1)("", missing))
		@inferred QGram(1)("", "")
	end

	@testset "Cosine" begin
		@test isnan(Cosine(2)("", "abc"))
		@test Cosine(2)("abc", "ccc") ≈ 1 atol = 1e-4
		@test Cosine(2)("leia", "leela") ≈ 0.7113249 atol = 1e-4
		@test Cosine(2)([1, 2, 3], [1, 2, 4]) ≈ 0.5
		@test Cosine(2)(graphemes("alborgów"), graphemes("amoniak")) ≈ Cosine(2)("alborgów", "amoniak")
		@test Cosine(2)("leia", "leela") ≈ 0.7113249 atol = 1e-4
		@test result_type(Cosine(2), "hello", "world") == typeof(float(1))
		@inferred Cosine(2)("", "")
		@test ismissing(Cosine(2)("", missing))
	end

	@testset "Jaccard" begin
		@test Jaccard(1)("", "abc") ≈ 1.0
		@test Jaccard(1)("abc", "ccc") ≈ 2/3 atol = 1e-4
		@test Jaccard(2)("leia", "leela") ≈ 0.83333 atol = 1e-4
		@test Jaccard(2)([1, 2, 3], [1, 2, 4]) ≈ 2/3 atol = 1e-4
		@test Jaccard(2)(graphemes("alborgów"), graphemes("amoniak")) ≈ Jaccard(2)("alborgów", "amoniak")
		@test Jaccard(2)("leia", "leela") ≈ 0.83333 atol = 1e-4
		@test result_type(Jaccard(1), "hello", "world") == typeof(float(1))
		@inferred Jaccard(1)("", "")
		@test ismissing(Jaccard(1)("", missing))
	end

	@testset "SorensenDice" begin
		@test SorensenDice(1)("night", "nacht") ≈ 0.4 atol = 1e-4
		@test SorensenDice(2)("night", "nacht") ≈ 0.75 atol = 1e-4
		@test SorensenDice(2)(graphemes("alborgów"), graphemes("amoniak")) ≈ SorensenDice(2)("alborgów", "amoniak")
		@test SorensenDice(2)("night", "nacht") ≈ 0.75 atol = 1e-4
		@test result_type(SorensenDice(1), "hello", "world") == typeof(float(1))
		@inferred SorensenDice(1)("", "")
		@test ismissing(SorensenDice(1)("", missing))
	end

	@testset "Overlap" begin
		@test Overlap(1)("night", "nacht") ≈ 0.4 atol = 1e-4
		@test Overlap(1)("context", "contact") ≈ .2 atol = 1e-4
		@test Overlap(1)("context", "contact") ≈ .2 atol = 1e-4
		@test result_type(Overlap(1), "hello", "world") == typeof(float(1))
		@inferred Overlap(1)("", "")
		@test ismissing(Overlap(1)("", missing))
	end

	@testset "MorisitaOverlap" begin
		# overlap for 'n', 'h', and 't' and 5 q-grams per string:
		@test MorisitaOverlap(1)("night", "nacht") == 0.4 # 1.0-((2*3)/(5*5/5 + 5*5/5))

		# overlap for 'o', 'n', 2-overlap for 'c' and 't' and 7 unique q-grams in total so multiplicity vectors
		# ms1 = [1, 1, 1, 2, 1, 1, 0]
		# ms2 = [2, 1, 1, 2, 0, 0, 1]
		# sum(ms1 .* ms2) = 8, sum(ms1 .^ 2) = 9, sum(ms2 .^ 2) = 11, sum(ms1) = 7, sum(ms2) = 7
		@test MorisitaOverlap(1)("context", "contact") ≈ .2 atol = 1e-4 # 1.0-((2*8)/(9*7/7 + 11*7/7)) = 16/20
		@test MorisitaOverlap(1)("context", "contact") ≈ .2 atol = 1e-4

		# Multiplicity vectors for 2-grams "co", "on", "nt", "te", "ex", "xt", "ta", "ac", "ct"
		# ms1 = [1, 1, 1, 1, 1, 1, 0, 0, 0]
		# ms2 = [1, 1, 1, 0, 0, 0, 1, 1, 1]
		# sum(ms1 .* ms2) = 3, sum(ms1 .^ 2) = 6, sum(ms2 .^ 2) = 6, sum(ms1) = 6, sum(ms2) = 6
		@test MorisitaOverlap(2)("context", "contact") == 0.5 # 1.0-((2*3)/(6*6/6 + 6*6/6))

		@test result_type(MorisitaOverlap(1), "hello", "world") == typeof(float(1))
		@inferred MorisitaOverlap(1)("", "")
		@test ismissing(MorisitaOverlap(1)("", missing))
	end

	@testset "NMD" begin
		# m(s1) = [1, 1, 1, 1, 1, 0, 0], m(s2) = [1, 0, 0, 1, 1, 1, 1]
		@test NMD(1)("night", "nacht") == 0.4 # (7-5)/5

		# ms1 = [1, 1, 1, 2, 1, 1, 0]
		# ms2 = [2, 1, 1, 2, 0, 0, 1]
		@test NMD(1)("context", "contact") ≈ 0.2857 atol = 1e-4 # ((2+1+1+2+1+1+1)-7)/(7)
		@test NMD(1)("context", "contact") ≈ 0.2857 atol = 1e-4

		# ms1 = [1, 1, 1, 1, 1, 1, 0, 0, 0]
		# ms2 = [1, 1, 1, 0, 0, 0, 1, 1, 1]
		@test NMD(2)("context", "contact") == 0.5 # ((1+1+1+1+1+1+1+1+1)-6)/6

		@test result_type(NMD(1), "hello", "world") == typeof(float(1))
		@inferred NMD(1)("", "")
		@test ismissing(NMD(1)("", missing))
	end

	@testset "QGramDict and QGramSortedVector counts qgrams" begin
		# To get something we can more easily compare to:
		stringify(p::Pair{<:AbstractString, <:Integer}) = (string(first(p)), last(p))
		stringify(p::Pair{V, <:Integer}) where {S<:AbstractString,V<:AbstractVector{S}} = (map(string, first(p)), last(p))
		sortedcounts(qc) = sort(collect(qc.counts), by = first)
		totuples(qc) = map(stringify, sortedcounts(qc))

		s1, s2   = "arnearne", "arnebeda"

		qd1, qd2 = QGramDict(s1, 2), QGramDict(s2, 2)
		@test totuples(qd1) == [("ar", 2), ("ea", 1), ("ne", 2), ("rn", 2)]
		@test totuples(qd2) == [("ar", 1), ("be", 1), ("da", 1), ("eb", 1), ("ed", 1), ("ne", 1), ("rn", 1)]

		qc1, qc2 = QGramSortedVector(s1, 2), QGramSortedVector(s2, 2)
		@test totuples(qc1) == [("ar", 2), ("ea", 1), ("ne", 2), ("rn", 2)]
		@test totuples(qc2) == [("ar", 1), ("be", 1), ("da", 1), ("eb", 1), ("ed", 1), ("ne", 1), ("rn", 1)]

		s3 = "rgówów"
		qd3a = QGramDict(s3, 2)
		@test totuples(qd3a) == [("gó", 1), ("rg", 1), ("wó", 1), ("ów", 2)]

		qd3b = QGramDict(graphemes(s3), 2)
		@test totuples(qd3b) == [(["g", "ó"], 1), (["r", "g"], 1), (["w", "ó"], 1), (["ó", "w"], 2)]

		qc3a = QGramSortedVector(s3, 2)
		@test totuples(qc3a) == [("gó", 1), ("rg", 1), ("wó", 1), ("ów", 2)]

		qd3b = QGramDict(graphemes(s3), 2)
		@test totuples(qd3b) == [(["g", "ó"], 1), (["r", "g"], 1), (["w", "ó"], 1), (["ó", "w"], 2)]
	end

	function partlyoverlappingstrings(sizerange, chars = nothing)
		l = rand(sizerange)
		str1 = isnothing(chars) ? randstring(l) : randstring(chars, l)
		ci1 = thisind(str1, rand(1:l))
		ci2 = thisind(str1, rand(ci1:l))
		copied = join(str1[ci1:ci2])
		prefix = isnothing(chars) ? randstring(ci1-1) : randstring(chars, ci1-1)
		slen = l - length(copied) - length(prefix)
		suffix = isnothing(chars) ? randstring(slen) : randstring(chars, slen)
		return str1, (prefix * copied * suffix)
	end

	@testset "Precalculation on unicode strings" begin
		Chars = vcat(map(collect, ["δσμΣèìòâôîêûÊÂÛ", 'a':'z', '0':'9'])...)
		for _ in 1:100
			qlen = rand(2:5)
			str1, str2 = partlyoverlappingstrings(6:100, Chars)
			dist = Jaccard(qlen)

			qd1 = QGramDict(str1, qlen)
			qd2 = QGramDict(str2, qlen)
			@test dist(str1, str2) == dist(qd1, qd2)

			qd1b = QGramDict(graphemes(str1), qlen)
			qd2b = QGramDict(graphemes(str2), qlen)
			@test dist(str1, str2) == dist(qd1b, qd2b)

			qc1 = QGramSortedVector(str1, qlen)
			qc2 = QGramSortedVector(str2, qlen)
			@test dist(str1, str2) == dist(qc1, qc2)

			qc1b = QGramSortedVector(graphemes(str1), qlen)
			qc2b = QGramSortedVector(graphemes(str2), qlen)
			@test dist(str1, str2) == dist(qc1b, qc2b)
		end
	end

	@testset "QGram distance on short strings" begin
		@test isnan(Overlap(2)( "1",  "2"))
		@test isnan(Jaccard(3)("s1", "s2"))
		@test isnan(Cosine(5)( "s1", "s2"))

		@test !isnan(Overlap(2)( "s1",  "s2"))
		@test !isnan(Jaccard(3)("st1", "st2"))
		@test !isnan(Cosine(5)( "stri1", "stri2"))

		@test !isnan(Jaccard(3)("st1", "str2"))
		@test !isnan(Jaccard(3)("str1", "st2"))
	end

	@testset "Differential testing of String, QGramDict, and QGramSortedVector" begin
		for D in [QGram, Cosine, Jaccard, SorensenDice, Overlap, MorisitaOverlap, NMD]
			for _ in 1:100
				qlen = rand(2:9)
				dist = D(qlen)
				str1, str2 = partlyoverlappingstrings(10:10000)

				# QGramDict gets same result as for standard string
				qd1 = QGramDict(str1, qlen)
				qd2 = QGramDict(str2, qlen)
				expected = dist(str1, str2)
				@test expected == dist(qd1, qd2)

				# QGramSortedVector gets same result as for standard string
				qc1 = QGramSortedVector(str1, qlen)
				qc2 = QGramSortedVector(str2, qlen)
				@test expected == dist(qc1, qc2)
			end
		end
	end

	strings = [
	("martha", "marhta"),
	("dwayne", "duane") ,
	("dixon", "dicksonx"),
	("william", "williams"),
	("", "foo"),
	("a", "a"),
	("abc", "xyz"),
	("abc", "ccc"),
	("kitten", "sitting"),
	("saturday", "sunday"),
	("hi, my name is", "my name is"),
	("alborgów", "amoniak"),
	("cape sand recycling ", "edith ann graham"),
	( "jellyifhs", "jellyfish"),
	("ifhs", "fish"),
	("leia", "leela"),
	]

	solutions = ((Levenshtein(), [2  2  4  1  3  0  3  2  3  3  4  6 17  3  3  2]),
			(OptimalStringAlignement(), [1  2  4  1  3  0  3  2  3  3  4  6 17  2  2  2]),
			(Jaro(), [0.05555556 0.17777778 0.23333333 0.04166667 1.00000000 0.00000000 1.00000000 0.44444444 0.25396825 0.2805556 0.2285714 0.48809524 0.3916667 0.07407407 0.16666667 0.21666667]),
			(QGram(1), [0   3   3   1 3  0   6   4   5   4   4  11  14   0   0   3]),
			(QGram(2), [  6   7   7   1 2 0   4   4   7   8   4  13  32   8   6   5]),
			(Jaccard(1), [0.0 0.4285714 0.3750000 0.1666667       1.0 0.0 1.0000000 0.6666667 0.5714286 0.3750000 0.2000000 0.8333333 0.5000000 0.0 0.0 0.2500000]),
			(Jaccard(2),  [ 0.7500000 0.8750000 0.7777778 0.1428571       1.0     NaN 1.0000000 1.0000000 0.7777778 0.8000000 0.3076923 1.0000000 0.9696970 0.6666667 1.0000000 0.8333333]),
			(Cosine(2), [0.6000000 0.7763932 0.6220355 0.0741799  NaN  NaN 1.0000000 1.0000000 0.6348516 0.6619383 0.1679497 1.0000000 0.9407651 0.5000000 1.0000000 0.7113249]))
	# Test with R package StringDist
	for x in solutions
		dist, solution = x
		for i in eachindex(solution)
			if isnan(dist(strings[i]...))
				@test isnan(solution[i])
			else
				@test dist(strings[i]...) ≈ solution[i] atol = 1e-4
			end
		end
	end
	# test  RatcliffObershelp
	solution = [83, 73, 62, 93, 0, 100, 0, 33, 62, 71, 83, 27, 33, 78, 50, 67]
	for i in eachindex(strings)
		@test round(Int, (1 - RatcliffObershelp()(strings[i]...)) * 100) ≈ solution[i] atol = 1e-4
	end

	# test max_dist
	for i in eachindex(strings)
		d = Levenshtein()(strings[i]...)
		@test Levenshtein()(strings[i]...; max_dist = d) == d
		d = OptimalStringAlignement()(strings[i]...)
		@test OptimalStringAlignement()(strings[i]...; max_dist = d) == d
	end
end



#= R test
library(stringdist)
strings = matrix(data = c(
"martha", "marhta",
"dwayne", "duane",
"dixon", "dicksonx",
"william", "williams",
"", "foo",
"a", "a",
"abc", "xyz",
"abc", "ccc",
"kitten", "sitting",
"saturday", "sunday",
"hi, my name is", "my name is",
"alborgów", "amoniak",
"cape sand recycling ", "edith ann graham",
 "jellyifhs", "jellyfish",
"ifhs", "fish",
"leia", "leela"),
nrow = 2
)
stringdist(strings[1,], strings[2,], method = "jw", p = 0)
stringdist(strings[1,], strings[2,], method = "jw", p = 0.1)
stringdist(strings[1,], strings[2,], method = "qgram", q = 1)

=#




#= Fuzzywuzzy usesRatcliffObershelp  if python-Levenshtein not installed, fuzzywuzzy uses RatcliffObershelp)
from fuzzywuzzy import fuzz
strings = [
("martha", "marhta"),
("dwayne", "duane") ,
("dixon", "dicksonx"),
("william", "williams"),
("", "foo"),
("a", "a"),
("abc", "xyz"),
("abc", "ccc"),
("kitten", "sitting"),
("saturday", "sunday"),
("hi, my name is", "my name is"),
("alborgów", "amoniak"),
("cape sand recycling ", "edith ann graham"),
( "jellyifhs", "jellyfish"),
("ifhs", "fish"),
("leia", "leela"),
]
for x in strings:
   print(fuzz.ratio(x[0], x[1]))
=#

