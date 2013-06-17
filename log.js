///////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2008, HC.software, All rights reserved.
//
// $Revision: 0.9 $
//     $Date: 08/05/08
//
// CREATOR:   ivan.yao
// UPDATE :   Tom.ding  04/24/2012
// UPDATE :	  Tom.ding  11/20/2012 for 8.0 & higher version.
//
//
// DESCRIPTION:
//    eScript  - Siebel Common Operation Interface
//
//    08/05/08 : 
//               This file is directly modified to conform
//
// USAGE:
//			Log(context,suf);
//          object.log();
///////////////////////////////////////////////////////////////////////////////

//-------------- init prototype --------------
Array.prototype.type = "Array";
Number.prototype.type = "Number";
String.prototype.type = "String";
Boolean.prototype.type = "Boolean";
Date.prototype.type = "Date";
Object.prototype.type = "Object";
//Object.prototype.log = function(){Log(this)};
//----------------- end init -----------------

function Date_Today(bWithTime,bWithMillSec)
{
	return Format_Date((new Date()),bWithTime,bWithMillSec);
}

function Format_Array(context,index)
{
	var sIndent = Format_Indent(index);
	var sFormatStr = "";
	var tmp;
	
    for(var key in context){
		tmp = context[key];
		if(typeof(tmp) == "object" && typeof(context.GetProperty) == "function"){
			sFormatStr += sIndent + "[" + key + "] is a PropertySet{\n";
			sFormatStr += Format_PropertySet(tmp,index + 1) + "\n";
			sFormatStr += sIndent + "}\n";
			continue;
		}
		switch(tmp.type){
			case "Array":
				sFormatStr += sIndent + "[" + key + "] is a " + tmp.type + "{\n";
				sFormatStr += Format_Array(tmp,index + 1) + "\n";
				sFormatStr += sIndent + "}\n";
				break;
			case "Object":
				sFormatStr += sIndent + "[" + key + "] is a " + tmp.type + "{\n";
				sFormatStr += Format_Object(tmp,index + 1) + "\n";
				sFormatStr += sIndent + "}\n";
				break;
			default:
				sFormatStr += sIndent + "[" + key + "] = " + tmp + "\n";
				break;
		}
		tmp = null;
	}

	return sFormatStr;
}

function Format_Content(context,sVarName)
{
	var sConverterToStr = "TYPE : ";
	
	if(context == null){
		context = "null";
		sConverterToStr += "Object";
	}
	else{
		sConverterToStr += (typeof(context) == "object")?(typeof(context.GetProperty) == 'function'?'PropertySet':'Object'):context.type;	
	}
	
	sConverterToStr += "\n";
	
	if(sVarName){
		sConverterToStr += sVarName + " : ";
	}
	
	if(context.type == "Array" || context.type == "Object" || typeof(context) == "object"){
		sConverterToStr += "\n";
	}
	return (sConverterToStr + Format_Switch(context) + "\n");
}

function Format_Date(oDate,bWithTime,bWithMillSec)
{
	var sFmtDate = "";

	sFmtDate = oDate.getFullYear() + "-" + (oDate.getMonth() + 1) + "-" + oDate.getDate();   

	if (bWithTime) sFmtDate += " " +  oDate.getHours() + ":" + oDate.getMinutes() + ":" + oDate.getSeconds();
	if (bWithMillSec) sFmtDate +=  ":" + oDate.getMilliseconds();

	return sFmtDate;
}

function Format_Indent(&iLevel)
{
	if ((iLevel == "") || (typeof(iLevel) == "undefined")) {
		iLevel = 0;
	}
	var indent = "";
	for (var x = 0; x < iLevel; x++){
		indent += "\t";
	}
	return indent;
}

function Format_Object(context,index)
{
	var sIndent = Format_Indent(index);
	var sFormatStr = "";
	var tmp;
	
    for(var i in context){
		if(!context.hasOwnProperty(i)) continue; //ignore the prototype property.
		tmp = context[i];
		if(typeof(tmp) == "object" && typeof(context.GetProperty) == "function"){
			sFormatStr += sIndent + "[" + key + "] is a PropertySet{\n";
			sFormatStr += Format_PropertySet(tmp,index + 1) + "\n";
			sFormatStr += sIndent + "}\n";
			continue;
		}
		switch(tmp.type){
			case "Array":
				sFormatStr += sIndent + "[" + i + "] is a " + tmp.type + "{\n";
				sFormatStr += Format_Array(tmp,index + 1) + "\n";
				sFormatStr += sIndent + "}\n";
				break;
			case "Object":				
				sFormatStr += sIndent + "[" + i + "] is a " + tmp.type + "{\n";
				sFormatStr += Format_Object(tmp,index + 1) + "\n";
				sFormatStr += sIndent + "}\n";
				break;
			default:
				sFormatStr += sIndent + "[" + i + "] = " + Format_Switch(tmp) + "\n";
				break;
		}
		tmp = null;	
	}
	return sFormatStr;
}

function Format_PropertySet(oPS,iLevel)
{
	var sConverted = "";
	var indent = Format_Indent(iLevel);
	
	try{
		var psType = oPS.GetType();
		var psValue = oPS.GetValue();
		sConverted = indent + "Type: " + psType + " Value: " + psValue + "\n";
	}
	catch(e){
		sConverted += indent + "BAD DATA IN PROPERTY HEADER";
	}
	
	var propName = oPS.GetFirstProperty();
	while (propName != ""){
		try{
			var propValue = oPS.GetProperty(propName);
		}
		catch(e){
			sConverted += indent + "BAD DATA IN PROPERTY DATA";
		}
		
		sConverted += indent + propName + " = " + propValue + "\n";
		propName = oPS.GetNextProperty();
	}
	
	var iChildCount = oPS.GetChildCount();
	for (var x = 0; x < iChildCount; x++){
	    sConverted += indent + "CHILD PROPERTY SET " + x +"\n";
	    sConverted += Format_PropertySet(oPS.GetChild(x), (iLevel + 1));
	}	
	return sConverted;
}

function Format_Switch(context)
{
	var sFormatStr = "";
	
	if(typeof(context) == "object" && typeof(context.GetProperty) == "function"){
		return Format_PropertySet(context);
	}
	if(typeof(context) == "object"){
		return Format_Object(context);
	}
	switch(context.type){
		case "String":
		case "Boolean":
		case "Number":
			sFormatStr += context;
			break;	
		case "Date":
			sFormatStr += Format_Date(context,true,true);
			break;
		case "Array":
			sFormatStr += Format_Array(context);
			break;
		case "Object":
			sFormatStr += Format_Object(context);
			break;
		default:break;
	}
	return sFormatStr;
}

function Log(oObject,sVarName)
{
	try
	{
		var oFile = Clib.fopen("C:\\Temp\\SiebelLog_" + TheApplication().LoginName() + "_" + Date_Today(false,false) + ".log", "au");
		if(!sVarName){
			sVarName = "";
		}
		Clib.fputs("------------------------" + Date_Today(true,true) + "--------------------------\n",oFile);	
		Clib.fputs(Format_Content(oObject,sVarName),oFile);
		Clib.fputs("------------------------------------------------------------------------\n\n",oFile);
	}
	catch(e)
	{
		TheApplication().RaiseErrorText(defined(e.errText)?e.errText:e.toString());
	}
	finally
	{
		if (oFile) Clib.fclose(oFile);
	}
}