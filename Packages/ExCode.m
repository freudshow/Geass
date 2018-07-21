ExEncrypt::usage = "ExEncrypt[Str,Way]以方式Way给出输入代码Str的超编码";
ExDecrypt::usage = "ExDecrypt[Str,Way]以方式Way给出输入代码Str的超解码";
ListToPolish::usage =
	"ListToPolish[list]转换一个逆波兰表达式列表,如果有多个表达式混在一个栈,返回会自动划分\r
    注意算子(Plus)和运算符(+)的区别.运算符要用字符串,算子无所谓,允许使用字母.例:\r
    ListToPolish[{4,2,3,\"*\"}]返回结果是{4,3*2}\r
    ListToPolish[{4,2,3,Times}]返回结果是{Times[3,2,4]}\r\r
    ListToPolish[{1,\"2\",\"+\",3,4,\"+\",\"*\",Exp,10,\"!\",\"Sqrt\",70,\"42\",GCD,Plus,\"a\",b,\"+\",c,d,\"+\",\"*\",\"e\",\"/\",n,\"^\"}]\r
    对于数字、字母以及非算符来说是否是字符串形式是无所谓的.";
ExCode$Version = "V0.1";
ExCode$Environment = "V11.0+";
ExCode$LastUpdate = "2016-11-11";
ExCode::usage = "程序包的说明,这里抄一遍";
Begin["`ExCode`"];
SetAttributes[{CodeToCipher, ExEncrypt}, HoldAll];
CodeToCipher[Str_] := Block[
	{密匙, 输出},
	密匙 = GenerateSymmetricKey[Method -> <|"Cipher" -> "AES256",
		"InitializationVector" -> ByteArray[{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}]|>];
	输出 = Join[Normal@密匙["Key"], Normal@Encrypt[密匙, Compress@Hold@Str]["Data"]]
];
CipherToCode[Str_, Safe_ : False] := Block[
	{破译密匙, 破译内容},
	破译密匙 = SymmetricKey[<|"Cipher" -> "AES256", "BlockMode" -> "CBC", "Key" -> ByteArray[Str[[1 ;; 32]]],
		"InitializationVector" -> ByteArray["AQIDBAUGBwgJCgsMDQ4PEA=="]|>];
	破译内容 = EncryptedObject[<|"Data" -> ByteArray[Str[[33 ;; -1]]],
		"InitializationVector" -> ByteArray["AQIDBAUGBwgJCgsMDQ4PEA=="], "OriginalForm" -> String|>];
	If[Safe, Uncompress@Decrypt[破译密匙, 破译内容], ReleaseHold@Uncompress@Decrypt[破译密匙, 破译内容]]
];
Options[ExEncrypt] = {Method -> "AES"};
CharSet["MarySue"] := StringPartition[
	"丝丹丽之乐云亚仪伊优伤佳依俏倩倾兮兰冰凌凝凡凤凪利千华卿可叶吉君咏哀嘉园城基塔墨夏多奥如妍妖妙妮妲姆姣姬娅娜娣娥娴婉婵婷媛嫩宁安宜寂\
	寇寒岚巧希幻幽弥彩影御心思怡恋恩悠悦情慕慧拉文斯春昭晓晗晶曦曼月朵枝枫柒柔格桂梅梦樱欢欣殇残毓沫泪洁洛浅海涅淑清温渺滢澜澪灵烟然燕燢爱爽玉玖\
	玛玥玫环玲珊珍珠琉琦琪琬琰琳琴琼瑗瑞瑟瑰瑶瑷璃璎璐璧白百盘眉真碎离秀秋筱米素紫红纨纯纱绯缈美羽翠翼育舒舞艳艺艾芊芝芬花芳芸苏苑英茉茗茜茹荔荷\
	莉莎莲莳莹莺菁菲萌萍萝萦萨落蒂蓉蓓蓝蔷蕊蕴蕾薇薰蝶融血裳语贞迷邪铃银锦阳陌雁雅雨雪霄霜霞霭露青静音韵颖颜风飘香馥馨魂魅魑鸢黎黛", 1
];
ExEncryptMarySue[expr_] := Block[
	{byte, ans, ins},
	byte = Normal@BinarySerialize[{RandomInteger[100], expr}, PerformanceGoal -> "Size"];
	ans = set[[IntegerDigits[FromDigits[Reverse@byte, 256], Length[CharSet["MarySue"]]] + 1]];
	ins = Select[Accumulate[{RandomInteger[{3, 6}]} ~ Join ~ RandomInteger[{2, 8}, Length@ans]], # < Length@ans&];
	StringInsert[StringJoin[ans], "\[CenterDot]", ins]
];
ExDecryptMarySue[str_] := Block[
	{byte, ans, truth},
	ans = StringPartition[StringDelete[str, "\[CenterDot]"], 1];
	byte = Flatten[FirstPosition[CharSet["MarySue"], #]& /@ ans] - 1;
	truth = Reverse@IntegerDigits[FromDigits[byte, Length[set]], 256];
	BinaryDeserialize[ByteArray@truth] // Last
];
ExEncryptTemp[Str_, Language -> "MarySue"] := Block[{ans, ins},
	ans = IntegerDigits[FromDigits[CodeToCipher@Str, 256], Length@CharSet[Language -> "MarySue"]] + 1;
	ins = Select[Accumulate[{RandomInteger[{2, 8}]} ~ Join ~ RandomInteger[{1, 9}, Length@ans]], # < Length@ans&];
	StringInsert[StringJoin[CharAss[Language -> "MarySue"] /@ ans], "\[CenterDot]", ins]];
ExDecryptTemp[Str_String, Language -> "MarySue", Safe_ : False] := Block[{input, res},
	input = CharAnti[Language -> "MarySue"] /@ StringPartition[StringDelete[Str, "\[CenterDot]"], 1];
	res = IntegerDigits[FromDigits[input - 1, Length@CharSet[Language -> "MarySue"]], 256];
	CipherToCode[res, Safe]];
CharSetTemp[Language -> name_] := Alphabet[Language -> name];
CharSetTemp[Language -> "Chinese"] := StringPartition[FromCharacterCode[Range[13312, 40869]], 1];
CharSetTemp[Language -> "ASCII"] := StringPartition[FromCharacterCode[Range[32, 126]], 1];
CharSetTemp[Language -> "长者之问"] := StringPartition["苟利国家生死以岂因祸福避趋之", 1];
ExEncryptTemp[Str_, Language -> "长者之问"] := Block[{ans, ins},
	ans = IntegerDigits[FromDigits[CodeToCipher@Str, 256], Length@CharSet[Language -> "长者之问"]] + 1;
	ins = Select[Accumulate[{RandomInteger[{2, 5}]} ~ Join ~ RandomInteger[{5, 20}, Length@ans]], # < Length@ans&];
	StringInsert[StringJoin[CharAss[Language -> "长者之问"] /@ ans], "?\r", ins] <> "?"];
ExDecryptTemp[Str_String, Language -> "长者之问", Safe_ : False] := Block[
	{input, res},
	input = CharAnti[Language -> "长者之问"] /@ StringPartition[StringDelete[StringJoin@Str, {"?", "\n"}], 1];
	res = IntegerDigits[FromDigits[input - 1, Length@CharSet[Language -> "长者之问"]], 256];
	CipherToCode[res, Safe]
];
SetAttributes[{ExEncrypt,ExEncryptMarySue}, HoldAllComplete];
ListToExpression[list_] := list //. ({x___, PatternSequence[a_, u : #, b_], y___} :> {x, u[a, b], y}& /@ {Power | Log | Surd, Times | Divide, Plus | Subtract});
OperatorRiffle[exp_, oper_ : {Times, Divide, Plus, Subtract}] := Grid[{#, ListToExpression@#}& /@ (Riffle[exp, #]& /@ Tuples[oper, Length@exp - 1]), Alignment -> Left];
RPNexpression`infix = {"+", "-", "*", "*", "/", "/", "^", ".", "==", "==", "!=", "!=", "<", ">", "<=", "<=", ">=", ">=", "&&", "||"};
RPNexpression`prefix = {"Sqrt", "CubeRoot", "Log", "Log10", "Log2", "Exp", "Sin", "Cos", "Tan", "ArcSin", "ArcCos", "ArcTan", "Sinh", "Cosh", "Tanh",
	"ArcSinh", "ArcCosh", "ArcTanh", "N", "Abs", "Arg", "Re", "Im", "Round", "Floor", "Ceiling", "IntegerPart", "FractionalPart", "Gamma", "Erf", "Erfc", "InverseErf", "InverseErfc"};
RPNexpression`prefix2 = {"Mod", "Quotient", "GCD", "LCM", "Binomial", "Surd"};
RPNexpression`prefixall = {"Plus", "Times", "Min", "Max", "Power"};
RPNexpression`postfix = {"!"};
RPNexpression::short = "请输入合法的逆波兰表达式!";
RPNexpression[stack_, {op_, rest___}] := Which[MemberQ[RPNexpression`infix, op],
	If[Length[stack] < 2, Message[RPNexpression::short, op, 2];
	RPNexpression[stack, {rest}], RPNexpression[Append[Drop[stack, -2],
		ToExpression["#1" <> op <> "#2&"] @@ Take[stack, -2]], {rest}]],
	MemberQ[RPNexpression`prefix, op], If[Length[stack] < 1,
		Message[RPNexpression::short, op, 1];RPNexpression[stack, {rest}],
		RPNexpression[Append[Drop[stack, -1], ToExpression[op]@stack[[-1]]], {rest}]],
	MemberQ[RPNexpression`prefix2, op], If[Length[stack] < 2,
		Message[RPNexpression::short, op, 2];RPNexpression[stack, {rest}],
		RPNexpression[Append[Drop[stack, -2], ToExpression[op] @@ Take[stack, -2]], {rest}]],
	MemberQ[RPNexpression`prefixall, op], RPNexpression[{ToExpression[op] @@ stack}, {rest}],
	MemberQ[RPNexpression`postfix, op], If[Length[stack] < 1, Message[RPNexpression::short, op, 1];
	RPNexpression[stack, {rest}], RPNexpression[Append[Drop[stack, -1],
		ToExpression["#" <> op <> "&"]@stack[[-1]]], {rest}]], True,
	RPNexpression[Append[stack, ToExpression[op]], {rest}]];
ListToPolish[list_] := First@RPNexpression[{}, ToString /@ list];
SetAttributes[Lispify, HoldAll];
Lispify[h_[args___]] := Prepend[Lispify /@ Unevaluated@{args}, Lispify[h]];
Lispify[s_ /; AtomQ[s]] := s;
FooReverse[a_?AtomQ] := a;
FooReverse[a_?ListQ] := Reverse[a];
ExpressionToList[exp_] := Flatten[Reverse@Map[FooReverse, Lispify[Unevaluated[exp]], Infinity]];
End[] ;
EndPackage[];