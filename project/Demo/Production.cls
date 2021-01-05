Class Demo.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="Demo.Production" TestingEnabled="false" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="AutoSend" Category="" ClassName="Demo.Service.AutoSend" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
  </Item>
  <Item Name="AutoSend2" Category="" ClassName="Demo.Service.AutoSend2" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
  </Item>
  <Item Name="AutoSend3" Category="" ClassName="Demo.Service.AutoSend3" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
  </Item>
  <Item Name="StoreLocalDB" Category="" ClassName="Demo.Operation.StoreLocalDB" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
  </Item>
  <Item Name="StoreLocalDB2" Category="" ClassName="Demo.Operation.StoreLocalDB2" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
  </Item>
  <Item Name="StoreLocalDB3" Category="" ClassName="Demo.Operation.StoreLocalDB3" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
  </Item>
  <Item Name="Direct" Category="" ClassName="Demo.Service.Direct" PoolSize="0" Enabled="true" Foreground="true" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="RoutingEngine" Category="" ClassName="EnsLib.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="BusinessRuleName">Demo.RoutingEngineRoutingRule</Setting>
  </Item>
  <Item Name="EnsLib.File.PassthroughService" Category="" ClassName="EnsLib.File.PassthroughService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/home/irisowner/upload/local/</Setting>
    <Setting Target="Adapter" Name="FileSpec">*.txt</Setting>
    <Setting Target="Host" Name="TargetConfigNames">EnsLib.File.PassthroughOperation</Setting>
    <Setting Target="Adapter" Name="ArchivePath">/home/irisowner/upload/local_arc/</Setting>
  </Item>
  <Item Name="EnsLib.File.PassthroughOperation" Category="" ClassName="EnsLib.File.PassthroughOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/home/irisowner/upload/local_out/</Setting>
  </Item>
</Production>
}

}
