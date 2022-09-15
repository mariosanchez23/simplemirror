Class User.Report.Record2 Extends (%Persistent, %XML.Adaptor) [ ProcedureBlock ]
{

Property orderid As %String [ SqlColumnNumber = 2 ];

Property data1 As %String [ SqlColumnNumber = 3 ];

Property data2 As %String [ SqlColumnNumber = 4 ];

Property memo As %String [ SqlColumnNumber = 5 ];

index pkey on orderid [ Unique ];

}
