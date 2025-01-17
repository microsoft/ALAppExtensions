namespace Microsoft.DataMigration;

using System.Migration;

page 40030 "Table Mappings"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Table Mappings";
    InherentPermissions = X;
    InherentEntitlements = X;

    layout
    {
        area(Content)
        {
            repeater(Mappings)
            {
                field(ID; Rec.ID)
                {
                    ToolTip = 'Specifies the ID.';
                }
                field(FromTableName; Rec."From Table Name")
                {
                    Tooltip = 'Specifies the From Table Name';
                }
                field(FromTableSQLName; Rec."From Table SQL Name")
                {
                    Tooltip = 'Specifies the From Table SQL Name';
                }
                field(FromAppID; Rec."From APP ID")
                {
                    Tooltip = 'Specifies the From APP ID';
                }
                field(FromAppName; Rec."From App Name")
                {
                    Tooltip = 'Specifies the From App Name';
                }
                field(FromIsExtensionTable; Rec."From Is Extension Table")
                {
                    Tooltip = 'Specifies the From Is Extension Table';
                }
                field(FromBaseTableName; Rec."From Base Table Name")
                {
                    Tooltip = 'Specifies the From Base Table Name';
                }
                field(FromBaseTableSQLName; Rec."From Base Table SQL Name")
                {
                    Tooltip = 'Specifies the From Base Table SQL Name';
                }
                field(ToTableName; Rec."To Table Name")
                {
                    Tooltip = 'Specifies the To Table Name';
                }
                field(ToTableSQLName; Rec."To Table SQL Name")
                {
                    Tooltip = 'Specifies the To Table SQL Name';
                }
                field(ToAppId; Rec."To APP ID")
                {
                    Tooltip = 'Specifies the To APP ID';
                }
                field(ToAppName; Rec."To App Name")
                {
                    Tooltip = 'Specifies the To App Name';
                }
                field(ToIsExtensionTable; Rec."To Is Extension Table")
                {
                    Tooltip = 'Specifies the To Is Extension Table';
                }
                field(ToBaseTableName; Rec."To Base Table Name")
                {
                    Tooltip = 'Specifies the To Base Table Name';
                }
                field(ToBaseTableSQLName; Rec."To Base Table SQL Name")
                {
                    Tooltip = 'Specifies the To Base Table SQL Name';
                }
                field(InserterAppId; Rec."Inserter App ID")
                {
                    Tooltip = 'Specifies the Inserter App ID';
                }
                field(AppliesFromBCMajorRelease; Rec."Applies From BC Major Release")
                {
                    Tooltip = 'Specifies the Applies From BC Major Release';
                }
                field(AppliesFromBCMinorRelease; Rec."Applies From BC Minor Release")
                {
                    Tooltip = 'Specifies the Applies From BC Minor Release';
                }
                field(PerCompany; Rec."Per Company")
                {
                    Tooltip = 'Specifies the Per Company';
                }
                field(FromTableId; Rec."From Table ID")
                {
                    Tooltip = 'Specifies the From Table ID';
                }
                field(ToTableID; Rec."To Table ID")
                {
                    Tooltip = 'Specifies the To Table ID';
                }
            }
        }
    }
}