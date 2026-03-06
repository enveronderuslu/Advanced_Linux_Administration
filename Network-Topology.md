# Network Topology Diagram

```xml
<mxfile host="app.diagrams.net" modified="2024-03-21T00:00:00.000Z" agent="Gemini" version="21.0.0">
  <diagram id="pfsense-final-topology" name="pfSense Complete Topology">
    <mxGraphModel dx="1422" dy="762" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="827" pageHeight="1169" math="0" shadow="0">
      <root>
        <mxCell id="0" />
        <mxCell id="1" parent="0" />
        
        <mxCell id="wan_cloud" value="INTERNET" style="ellipse;shape=cloud;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="1">
          <mxGeometry x="340" y="20" width="120" height="80" as="geometry" />
        </mxCell>
        
        <mxCell id="pfsense" value="&lt;b&gt;pfSense Firewall&lt;/b&gt;&lt;br&gt;(KVM VM)" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#f8cecc;strokeColor=#b85450;strokeWidth=2;" vertex="1" parent="1">
          <mxGeometry x="320" y="160" width="160" height="100" as="geometry" />
        </mxCell>
        
        <mxCell id="wan_line" value="WAN (vtnet0)" style="endArrow=classic;startArrow=classic;html=1;entryX=0.5;entryY=1;entryDx=0;entryDy=0;exitX=0.5;exitY=0;exitDx=0;exitDy=0;" edge="1" parent="1" source="pfsense" target="wan_cloud">
          <mxGeometry width="50" height="50" relative="1" as="geometry" />
        </mxCell>

        <mxCell id="dmz_nic" value="&lt;b&gt;DMZ (Frontend)&lt;/b&gt;&lt;br&gt;NIC: vtnet2&lt;br&gt;10.0.30.1/24" style="rounded=0;whiteSpace=wrap;html=1;fillColor=#f8cecc;strokeColor=#b85450;strokeWidth=3;" vertex="1" parent="1">
          <mxGeometry x="40" y="180" width="140" height="60" as="geometry" />
        </mxCell>
        <mxCell id="dmz_line" value="Physical NIC" style="endArrow=classic;startArrow=classic;html=1;exitX=1;exitY=0.5;exitDx=0;exitDy=0;entryX=0;entryY=0.5;entryDx=0;entryDy=0;strokeColor=#b85450;strokeWidth=2;" edge="1" parent="1" source="dmz_nic" target="pfsense">
          <mxGeometry width="50" height="50" relative="1" as="geometry" />
        </mxCell>

        <mxCell id="trunk_line" value="LAN TRUNK (vtnet1)" style="endArrow=none;html=1;strokeWidth=4;strokeColor=#333333;" edge="1" parent="1">
          <mxGeometry x="400" y="260" width="50" height="50" as="geometry">
            <mxPoint x="400" y="340" as="sourcePoint" />
            <mxPoint x="400" y="260" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        
        <mxCell id="horizontal_bus" value="" style="endArrow=none;html=1;strokeWidth=4;strokeColor=#333333;" edge="1" parent="1">
          <mxGeometry width="50" height="50" relative="1" as="geometry">
            <mxPoint x="40" y="340" as="sourcePoint" />
            <mxPoint x="780" y="340" as="targetPoint" />
          </mxGeometry>
        </mxCell>

        <mxCell id="v10" value="MGMT (V10)&lt;br&gt;10.0.10.x" style="rounded=0;whiteSpace=wrap;html=1;fillColor=#e1d5e7;strokeColor=#9673a6;" vertex="1" parent="1"><mxGeometry x="40" y="400" width="100" height="50" as="geometry"/></mxCell>
        <mxCell id="l10" value="" style="endArrow=classic;html=1;strokeColor=#9673a6;strokeWidth=2;entryX=0.5;entryY=0;" edge="1" parent="1" target="v10"><mxGeometry relative="1" as="geometry"><mxPoint x="90" y="340" as="sourcePoint"/></mxGeometry></mxCell>

        <mxCell id="v20" value="Corp_LAN (V20)&lt;br&gt;10.0.20.x" style="rounded=0;whiteSpace=wrap;html=1;fillColor=#d5e8d4;strokeColor=#82b366;" vertex="1" parent="1"><mxGeometry x="165" y="400" width="100" height="50" as="geometry"/></mxCell>
        <mxCell id="l20" value="" style="endArrow=classic;html=1;strokeColor=#82b366;strokeWidth=2;entryX=0.5;entryY=0;" edge="1" parent="1" target="v20"><mxGeometry relative="1" as="geometry"><mxPoint x="215" y="340" as="sourcePoint"/></mxGeometry></mxCell>

        <mxCell id="v40" value="APP (V40)&lt;br&gt;10.0.40.x" style="rounded=0;whiteSpace=wrap;html=1;fillColor=#fff2cc;strokeColor=#d6b656;" vertex="1" parent="1"><mxGeometry x="290" y="400" width="100" height="50" as="geometry"/></mxCell>
        <mxCell id="l40" value="" style="endArrow=classic;html=1;strokeColor=#d6b656;strokeWidth=2;entryX=0.5;entryY=0;" edge="1" parent="1" target="v40"><mxGeometry relative="1" as="geometry"><mxPoint x="340" y="340" as="sourcePoint"/></mxGeometry></mxCell>

        <mxCell id="v50" value="DB (V50)&lt;br&gt;10.0.50.x" style="rounded=0;whiteSpace=wrap;html=1;fillColor=#ffe6cc;strokeColor=#d79b00;" vertex="1" parent="1"><mxGeometry x="415" y="400" width="100" height="50" as="geometry"/></mxCell>
        <mxCell id="l50" value="" style="endArrow=classic;html=1;strokeColor=#d79b00;strokeWidth=2;entryX=0.5;entryY=0;" edge="1" parent="1" target="v50"><mxGeometry relative="1" as="geometry"><mxPoint x="465" y="340" as="sourcePoint"/></mxGeometry></mxCell>

        <mxCell id="v60" value="SEC Ops (V60)&lt;br&gt;10.0.60.x" style="rounded=0;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="1"><mxGeometry x="540" y="400" width="100" height="50" as="geometry"/></mxCell>
        <mxCell id="l60" value="" style="endArrow=classic;html=1;strokeColor=#6c8ebf;strokeWidth=2;entryX=0.5;entryY=0;" edge="1" parent="1" target="v60"><mxGeometry relative="1" as="geometry"><mxPoint x="590" y="340" as="sourcePoint"/></mxGeometry></mxCell>

        <mxCell id="v70" value="GUEST (V70)&lt;br&gt;10.0.70.x" style="rounded=0;whiteSpace=wrap;html=1;fillColor=#f5f5f5;strokeColor=#666666;" vertex="1" parent="1"><mxGeometry x="665" y="400" width="100" height="50" as="geometry"/></mxCell>
        <mxCell id="l70" value="" style="endArrow=classic;html=1;strokeColor=#666666;strokeWidth=2;entryX=0.5;entryY=0;" edge="1" parent="1" target="v70"><mxGeometry relative="1" as="geometry"><mxPoint x="715" y="340" as="sourcePoint"/></mxGeometry></mxCell>
        
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```



```xml
<mxfile host="app.diagrams.net" modified="2024-03-21T00:00:00.000Z" agent="Gemini" version="21.0.0">
  <diagram id="security-matrix" name="pfSense Traffic Matrix">
    <mxGraphModel dx="1200" dy="800" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="827" pageHeight="1169" math="0" shadow="0">
      <root>
        <mxCell id="0" />
        <mxCell id="1" parent="0" />
        
        <mxCell id="node_dmz" value="&lt;b&gt;DMZ&lt;/b&gt;&lt;br&gt;(Frontend)" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#f8cecc;strokeColor=#b85450;" vertex="1" parent="1">
          <mxGeometry x="60" y="240" width="120" height="60" as="geometry" />
        </mxCell>
        
        <mxCell id="node_app" value="&lt;b&gt;APP&lt;/b&gt;&lt;br&gt;(Logic)" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#fff2cc;strokeColor=#d6b656;" vertex="1" parent="1">
          <mxGeometry x="280" y="240" width="120" height="60" as="geometry" />
        </mxCell>
        
        <mxCell id="node_db" value="&lt;b&gt;DB&lt;/b&gt;&lt;br&gt;(Backend)" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#ffe6cc;strokeColor=#d79b00;" vertex="1" parent="1">
          <mxGeometry x="500" y="240" width="120" height="60" as="geometry" />
        </mxCell>
        
        <mxCell id="node_sec" value="&lt;b&gt;SEC_Ops&lt;/b&gt;&lt;br&gt;(Admin)" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="1">
          <mxGeometry x="280" y="40" width="120" height="60" as="geometry" />
        </mxCell>
        
        <mxCell id="node_guest" value="&lt;b&gt;GUESTS&lt;/b&gt;" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#f5f5f5;strokeColor=#666666;" vertex="1" parent="1">
          <mxGeometry x="280" y="440" width="120" height="60" as="geometry" />
        </mxCell>

        <mxCell id="node_wan" value="&lt;b&gt;WAN&lt;/b&gt;&lt;br&gt;(Internet)" style="ellipse;shape=cloud;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="1">
          <mxGeometry x="700" y="230" width="120" height="80" as="geometry" />
        </mxCell>

        <mxCell id="flow_dmz_app" value="Allow (Port 80/443)" style="endArrow=classic;html=1;strokeColor=#2D7600;strokeWidth=2;exitX=1;exitY=0.5;exitDx=0;exitDy=0;entryX=0;entryY=0.5;entryDx=0;entryDy=0;" edge="1" parent="1" source="node_dmz" target="node_app">
          <mxGeometry width="50" height="50" relative="1" as="geometry" />
        </mxCell>
        
        <mxCell id="flow_app_db" value="Allow (SQL Port)" style="endArrow=classic;html=1;strokeColor=#2D7600;strokeWidth=2;exitX=1;exitY=0.5;exitDx=0;exitDy=0;entryX=0;entryY=0.5;entryDx=0;entryDy=0;" edge="1" parent="1" source="node_app" target="node_db">
          <mxGeometry width="50" height="50" relative="1" as="geometry" />
        </mxCell>
        
        <mxCell id="flow_sec_all" value="Full Admin Access" style="endArrow=classic;html=1;strokeColor=#2D7600;strokeWidth=1;dashed=1;entryX=0.5;entryY=0;entryDx=0;entryDy=0;exitX=0.5;exitY=1;exitDx=0;exitDy=0;" edge="1" parent="1" source="node_sec" target="node_app">
          <mxGeometry width="50" height="50" relative="1" as="geometry" />
        </mxCell>

        <mxCell id="flow_all_wan" value="Internet Access" style="endArrow=classic;html=1;strokeColor=#2D7600;strokeWidth=1;exitX=1;exitY=0.5;exitDx=0;exitDy=0;entryX=0.07;entryY=0.4;entryDx=0;entryDy=0;entryPerimeter=0;" edge="1" parent="1" source="node_db" target="node_wan">
          <mxGeometry width="50" height="50" relative="1" as="geometry" />
        </mxCell>

        <mxCell id="block_dmz_db" value="BLOCK" style="endArrow=none;html=1;strokeColor=#FF0000;strokeWidth=3;dashed=1;startArrow=cross;startFill=0;endFill=0;" edge="1" parent="1">
          <mxGeometry width="50" height="50" relative="1" as="geometry">
            <mxPoint x="140" y="310" as="sourcePoint" />
            <mxPoint x="490" y="310" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        
        <mxCell id="block_guest_int" value="BLOCK INTERNAL ACCESS" style="endArrow=none;html=1;strokeColor=#FF0000;strokeWidth=3;dashed=1;startArrow=cross;exitX=0.5;exitY=0;exitDx=0;exitDy=0;" edge="1" parent="1" source="node_guest">
          <mxGeometry width="50" height="50" relative="1" as="geometry">
            <mxPoint x="340" y="430" as="sourcePoint" />
            <mxPoint x="340" y="310" as="targetPoint" />
          </mxGeometry>
        </mxCell>

        <mxCell id="legend_allow" value="Green = Allowed" style="text;html=1;strokeColor=none;fillColor=none;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;fontColor=#2d7600;fontStyle=1" vertex="1" parent="1">
          <mxGeometry x="60" y="40" width="120" height="30" as="geometry" />
        </mxCell>
        <mxCell id="legend_block" value="Red = Blocked" style="text;html=1;strokeColor=none;fillColor=none;align=center;verticalAlign=middle;whiteSpace=wrap;rounded=0;fontColor=#ff0000;fontStyle=1" vertex="1" parent="1">
          <mxGeometry x="60" y="70" width="120" height="30" as="geometry" />
        </mxCell>
        
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```


Katman,Yapılandırma,Neden?
Ağ Ayrımı,Her sanal ağ için pfSense üzerinde ayrı bir VLAN Interface tanımlayın.,Mikro-segmentasyonun temeli budur.
DHCP,Her VLAN arayüzünde pfSense'in kendi DHCP servisini aktif edin.,Trafiği segment içinde tutar (East-West traffic control).
Statik Mapping,"Kritik sunucular için (DB, Web vb.) DHCP üzerinde Static ARP tanımlayın.","Sadece sizin tanımladığınız MAC adresine sahip cihazın o IP'yi almasını sağlayarak ""Identity"" (Kimlik) kontrolünü güçlendirirsiniz."
Firewall Kuralları,Default Allow kuralını kaldırın; sadece gereken portlara (Örn: Web -> DB sadece Port 3306) izin verin.,"Zero Trust'ın ""Least Privilege"" (En düşük ayrıcalık) kuralı."



# Neden ayri DNS kurulmali
Özellik,pfSense (Firewall) Rolü,Management DNS Sunucusu Rolü
Görünürlük,Paket bazlı log (Zor okunur),İsim bazlı log (Dashboard üzerinden izlenir)
Güvenlik,Port ve IP engelleme (L3/L4),Alan adı (Domain) engelleme (L7)
Yedeklilik,Tekil çözüm,Servislerin birbirinden ayrılması