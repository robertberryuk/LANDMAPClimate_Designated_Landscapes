<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis simplifyMaxScale="1" labelsEnabled="0" styleCategories="AllStyleCategories" readOnly="0" version="3.4.8-Madeira" simplifyLocal="1" maxScale="0" simplifyDrawingTol="1" hasScaleBasedVisibilityFlag="0" minScale="1e+08" simplifyAlgorithm="0" simplifyDrawingHints="1">
  <flags>
    <Identifiable>1</Identifiable>
    <Removable>1</Removable>
    <Searchable>1</Searchable>
  </flags>
  <renderer-v2 preprocessing="0" type="invertedPolygonRenderer" enableorderby="0" forceraster="0">
    <renderer-v2 type="RuleRenderer" symbollevels="0" enableorderby="0" forceraster="0">
      <rules key="{b18bfb76-2313-41b2-b009-21f7178e442d}">
        <rule key="{ad18edd1-1958-4848-8f17-5d9844227a79}" symbol="0" filter="$id = @atlas_featureid"/>
      </rules>
      <symbols>
        <symbol clip_to_extent="1" force_rhr="0" type="fill" name="0" alpha="0.65">
          <layer class="ShapeburstFill" locked="0" pass="0" enabled="1">
            <prop k="blur_radius" v="10"/>
            <prop k="color" v="0,0,0,255"/>
            <prop k="color1" v="0,0,255,255"/>
            <prop k="color2" v="0,255,0,255"/>
            <prop k="color_type" v="0"/>
            <prop k="discrete" v="0"/>
            <prop k="distance_map_unit_scale" v="3x:0,0,0,0,0,0"/>
            <prop k="distance_unit" v="MM"/>
            <prop k="gradient_color2" v="255,255,255,255"/>
            <prop k="ignore_rings" v="0"/>
            <prop k="max_distance" v="3"/>
            <prop k="offset" v="0,0"/>
            <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
            <prop k="offset_unit" v="MM"/>
            <prop k="rampType" v="gradient"/>
            <prop k="use_whole_shape" v="0"/>
            <data_defined_properties>
              <Option type="Map">
                <Option type="QString" name="name" value=""/>
                <Option name="properties"/>
                <Option type="QString" name="type" value="collection"/>
              </Option>
            </data_defined_properties>
          </layer>
        </symbol>
      </symbols>
    </renderer-v2>
  </renderer-v2>
  <customproperties>
    <property key="dualview/previewExpressions" value="OBJECTID"/>
    <property key="embeddedWidgets/count" value="0"/>
    <property key="variableNames"/>
    <property key="variableValues"/>
  </customproperties>
  <blendMode>0</blendMode>
  <featureBlendMode>0</featureBlendMode>
  <layerOpacity>1</layerOpacity>
  <SingleCategoryDiagramRenderer diagramType="Histogram" attributeLegend="1">
    <DiagramCategory backgroundAlpha="255" sizeType="MM" sizeScale="3x:0,0,0,0,0,0" penColor="#000000" maxScaleDenominator="1e+08" enabled="0" barWidth="5" minScaleDenominator="0" lineSizeType="MM" width="15" diagramOrientation="Up" scaleBasedVisibility="0" minimumSize="0" opacity="1" penAlpha="255" height="15" scaleDependency="Area" penWidth="0" rotationOffset="270" lineSizeScale="3x:0,0,0,0,0,0" labelPlacementMethod="XHeight" backgroundColor="#ffffff">
      <fontProperties description="MS Shell Dlg 2,8.25,-1,5,50,0,0,0,0,0" style=""/>
      <attribute label="" field="" color="#000000"/>
    </DiagramCategory>
  </SingleCategoryDiagramRenderer>
  <DiagramLayerSettings priority="0" dist="0" obstacle="0" showAll="1" zIndex="0" linePlacementFlags="18" placement="1">
    <properties>
      <Option type="Map">
        <Option type="QString" name="name" value=""/>
        <Option name="properties"/>
        <Option type="QString" name="type" value="collection"/>
      </Option>
    </properties>
  </DiagramLayerSettings>
  <geometryOptions removeDuplicateNodes="0" geometryPrecision="0">
    <activeChecks/>
    <checkConfiguration/>
  </geometryOptions>
  <fieldConfiguration>
    <field name="OBJECTID">
      <editWidget type="Range">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="NP_NAME">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="DESIG_DATE">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="Edit_Date">
      <editWidget type="DateTime">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="AREA_HA">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="ISIS_ID">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="Centre_X">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="Centre_Y">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="METADATA">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="GlobalID">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias index="0" field="OBJECTID" name=""/>
    <alias index="1" field="NP_NAME" name=""/>
    <alias index="2" field="DESIG_DATE" name=""/>
    <alias index="3" field="Edit_Date" name=""/>
    <alias index="4" field="AREA_HA" name=""/>
    <alias index="5" field="ISIS_ID" name=""/>
    <alias index="6" field="Centre_X" name=""/>
    <alias index="7" field="Centre_Y" name=""/>
    <alias index="8" field="METADATA" name=""/>
    <alias index="9" field="GlobalID" name=""/>
  </aliases>
  <excludeAttributesWMS/>
  <excludeAttributesWFS/>
  <defaults>
    <default applyOnUpdate="0" field="OBJECTID" expression=""/>
    <default applyOnUpdate="0" field="NP_NAME" expression=""/>
    <default applyOnUpdate="0" field="DESIG_DATE" expression=""/>
    <default applyOnUpdate="0" field="Edit_Date" expression=""/>
    <default applyOnUpdate="0" field="AREA_HA" expression=""/>
    <default applyOnUpdate="0" field="ISIS_ID" expression=""/>
    <default applyOnUpdate="0" field="Centre_X" expression=""/>
    <default applyOnUpdate="0" field="Centre_Y" expression=""/>
    <default applyOnUpdate="0" field="METADATA" expression=""/>
    <default applyOnUpdate="0" field="GlobalID" expression=""/>
  </defaults>
  <constraints>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="OBJECTID" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="NP_NAME" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="DESIG_DATE" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="Edit_Date" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="AREA_HA" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="ISIS_ID" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="Centre_X" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="Centre_Y" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="METADATA" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" field="GlobalID" unique_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint desc="" field="OBJECTID" exp=""/>
    <constraint desc="" field="NP_NAME" exp=""/>
    <constraint desc="" field="DESIG_DATE" exp=""/>
    <constraint desc="" field="Edit_Date" exp=""/>
    <constraint desc="" field="AREA_HA" exp=""/>
    <constraint desc="" field="ISIS_ID" exp=""/>
    <constraint desc="" field="Centre_X" exp=""/>
    <constraint desc="" field="Centre_Y" exp=""/>
    <constraint desc="" field="METADATA" exp=""/>
    <constraint desc="" field="GlobalID" exp=""/>
  </constraintExpressions>
  <expressionfields/>
  <attributeactions>
    <defaultAction key="Canvas" value="{00000000-0000-0000-0000-000000000000}"/>
  </attributeactions>
  <attributetableconfig sortExpression="" sortOrder="0" actionWidgetStyle="dropDown">
    <columns>
      <column width="-1" type="field" name="OBJECTID" hidden="0"/>
      <column width="-1" type="field" name="NP_NAME" hidden="0"/>
      <column width="-1" type="field" name="DESIG_DATE" hidden="0"/>
      <column width="-1" type="field" name="Edit_Date" hidden="0"/>
      <column width="-1" type="field" name="AREA_HA" hidden="0"/>
      <column width="-1" type="field" name="ISIS_ID" hidden="0"/>
      <column width="-1" type="field" name="Centre_X" hidden="0"/>
      <column width="-1" type="field" name="Centre_Y" hidden="0"/>
      <column width="186" type="field" name="METADATA" hidden="0"/>
      <column width="-1" type="field" name="GlobalID" hidden="0"/>
      <column width="-1" type="actions" hidden="1"/>
    </columns>
  </attributetableconfig>
  <conditionalstyles>
    <rowstyles/>
    <fieldstyles/>
  </conditionalstyles>
  <editform tolerant="1"></editform>
  <editforminit/>
  <editforminitcodesource>0</editforminitcodesource>
  <editforminitfilepath></editforminitfilepath>
  <editforminitcode><![CDATA[# -*- coding: utf-8 -*-
"""
QGIS forms can have a Python function that is called when the form is
opened.

Use this function to add extra logic to your forms.

Enter the name of the function in the "Python Init function"
field.
An example follows:
"""
from qgis.PyQt.QtWidgets import QWidget

def my_form_open(dialog, layer, feature):
	geom = feature.geometry()
	control = dialog.findChild(QWidget, "MyLineEdit")
]]></editforminitcode>
  <featformsuppress>0</featformsuppress>
  <editorlayout>generatedlayout</editorlayout>
  <editable>
    <field editable="1" name="AREA_HA"/>
    <field editable="1" name="Centre_X"/>
    <field editable="1" name="Centre_Y"/>
    <field editable="1" name="DESIG_DATE"/>
    <field editable="1" name="Edit_Date"/>
    <field editable="1" name="GlobalID"/>
    <field editable="1" name="ISIS_ID"/>
    <field editable="1" name="METADATA"/>
    <field editable="1" name="NP_NAME"/>
    <field editable="1" name="OBJECTID"/>
  </editable>
  <labelOnTop>
    <field labelOnTop="0" name="AREA_HA"/>
    <field labelOnTop="0" name="Centre_X"/>
    <field labelOnTop="0" name="Centre_Y"/>
    <field labelOnTop="0" name="DESIG_DATE"/>
    <field labelOnTop="0" name="Edit_Date"/>
    <field labelOnTop="0" name="GlobalID"/>
    <field labelOnTop="0" name="ISIS_ID"/>
    <field labelOnTop="0" name="METADATA"/>
    <field labelOnTop="0" name="NP_NAME"/>
    <field labelOnTop="0" name="OBJECTID"/>
  </labelOnTop>
  <widgets/>
  <previewExpression>OBJECTID</previewExpression>
  <mapTip></mapTip>
  <layerGeometryType>2</layerGeometryType>
</qgis>
