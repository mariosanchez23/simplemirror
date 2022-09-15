Class Demo.Operation.StoreLocalDB2 Extends Ens.BusinessOperation [ Language = objectscript ]
{

Parameter INVOCATION = "Queue";

Method ExecReport(pRequest As User.Report.Record, Output pResponse As Ens.Response) As %Status
{
	Set tSC=$$$OK
	Try {
		Set pResponse=##class(Ens.Response).%New()
		Set json=[].%FromJSON(pRequest.StringValue)
		Set p1=json.OrderId,p2=json.TimeStamp,p3=$ZDATETIME($H,3),p4=""
		&SQL(insert into User_Report.Record2 (orderid,data1,data2,memo) values (:p1,:p2,:p3,:p4))
		If SQLCODE'=0 { $$$LOGERROR("OrderId:"_p1_" SQLCODE:"_SQLCODE) }
	}
	Catch e {
		Set tSC=e.AsStatus()
	}

	h 10
	Return tSC
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="Ens.StringContainer"> 
		<Method>ExecReport</Method>
	</MapItem>	
</MapItems>
}

}
