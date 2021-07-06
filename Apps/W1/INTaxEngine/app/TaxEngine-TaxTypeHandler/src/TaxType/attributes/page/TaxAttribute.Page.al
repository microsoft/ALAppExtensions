page 20257 "Tax Attribute"
{
    Caption = 'Tax Attribute';
    PageType = Card;
    RefreshOnActivate = true;
    SourceTable = "Tax Attribute";
    layout
    {
        area(Content)
        {
            group(Group9)
            {
                Caption = 'General';
                group(Group2)
                {
                    Caption = '';
                    field(Name; Name)
                    {
                        ToolTip = 'Specifies the name of the parameter.';
                        ApplicationArea = Basic, Suite;
                    }
                    field(Type; Type)
                    {
                        ToolTip = 'Specifies the data type of the parameter.';
                        ApplicationArea = Basic, Suite;
                        trigger OnValidate();
                        begin
                            UpdateControlVisibility();
                        end;
                    }
                }
                group(Group11)
                {
                    Caption = '';
                    Visible = ValuesDrillDownVisible;
                    field(Values; GetValues())
                    {
                        Caption = 'Values';
                        Editable = false;
                        ToolTip = 'Specifies the values of a Input parameter. It is only applicable for Option typeparameters.';
                        ApplicationArea = Basic, Suite;
                        trigger OnDrillDown();
                        begin
                            OpenAttributeValues();
                        end;
                    }
                }
                group(Group14)
                {
                    Caption = '';
                    field("Visible on Interface"; "Visible on Interface")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies whether the parameter will appear on the tax Information fact box of Transaction.';
                    }
                    field(TableNameText; TableNameText2)
                    {
                        Caption = 'Reference Table Name';
                        ToolTip = 'Specifies table name that is mapped with the parameter.';
                        ApplicationArea = Basic, Suite;
                        trigger OnValidate();
                        begin
                            AppObjectHelper.SearchObject(ObjectType::Table, "Refrence Table ID", TableNameText2);
                            Validate("Refrence Table ID");
                        end;

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            AppObjectHelper.OpenObjectLookup(ObjectType::Table, Text, "Refrence Table ID", TableNameText2);
                            Validate("Refrence Table ID");
                        end;
                    }
                    field(FieldNameText; FieldNameText2)
                    {
                        Caption = 'Reference Field Name';
                        ToolTip = 'Specifies field name that is mapped with the parameter';
                        ApplicationArea = Basic, Suite;
                        trigger OnValidate();
                        begin
                            AppObjectHelper.SearchTableFieldOfType("Refrence Table ID", "Refrence Field ID", FieldNameText2, DatatypeMgmt.GetAttributeDataTypeToVariableDataType(Type));
                            Validate("Refrence Field ID");
                        end;

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            AppObjectHelper.OpenFieldLookupOfType("Refrence Table ID", "Refrence Field ID", FieldNameText2, Text, DatatypeMgmt.GetAttributeDataTypeToVariableDataType(Type));
                            Validate("Refrence Field ID");
                        end;
                    }
                    field(PageNameText; PageNameText2)
                    {
                        Caption = 'Lookup Page Name';
                        ToolTip = 'Specifies the Page name that is mapped with the parameter, this will open the Lookup of the linked page.';
                        ApplicationArea = Basic, Suite;
                        trigger OnValidate();
                        begin
                            AppObjectHelper.SearchObject(ObjectType::Page, "Lookup Page ID", PageNameText2);
                        end;

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            AppObjectHelper.OpenObjectLookup(ObjectType::Page, Text, "Lookup Page ID", PageNameText2);
                        end;
                    }
                    field("Grouped In SubLedger"; "Grouped In SubLedger")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the paramter will be used for grouping of records in tax ledger entries.';
                    }
                }
            }
            part(LinkedEntity; "Entity Mapped to Attributes")
            {
                Caption = 'Linked Entities';
                SubPageLink = "Attribute ID" = field("ID");
                ApplicationArea = Basic, Suite;
            }
        }

    }

    actions
    {
        area(Processing)
        {
            action(AttributeValues)
            {
                Caption = 'Attribute &Values';
                Enabled = ValuesDrillDownVisible;
                ToolTip = 'Opens a window in which you can define the values for the selected attribute.';
                ApplicationArea = Basic, Suite;
                Image = "CalculateInventory";
                RunObject = page "Tax Attribute Values";
                RunPageLink = "Attribute ID" = Field(ID);
            }

        }
    }

    var
        AppObjectHelper: Codeunit "App Object Helper";
        DatatypeMgmt: Codeunit "Use Case Data Type Mgmt.";
        ValuesDrillDownVisible: Boolean;
        UnitOfMeasureVisible: Boolean;
        TableNameText2: Text[30];
        PageNameText2: Text[30];
        FieldNameText2: Text[30];

    local procedure UpdateControlVisibility();
    begin
        ValuesDrillDownVisible := (Type = Type::Option);
        UnitOfMeasureVisible := (Type = Type::Decimal) or (Type = Type::Integer);
    end;

    local procedure FormatLine()
    begin
        if "Refrence Table ID" <> 0 then
            TableNameText2 := AppObjectHelper.GetObjectName(ObjectType::Table, "Refrence Table ID");

        if "Refrence Field ID" <> 0 then
            FieldNameText2 := AppObjectHelper.GetFieldName("Refrence Table ID", "Refrence Field ID");

        if "Lookup Page ID" <> 0 then
            PageNameText2 := AppObjectHelper.GetObjectName(ObjectType::Page, "Lookup Page ID");
    end;

    trigger OnOpenPage();
    begin
        UpdateControlVisibility();
    end;

    trigger OnAfterGetCurrRecord();
    begin
        UpdateControlVisibility();
        FormatLine();
    end;

    trigger OnAfterGetRecord();
    begin
        FormatLine();
    end;

    trigger OnNewRecord(xBelowxRec: Boolean)
    begin
        if GetFilter("Tax Type") <> '' then
            Validate("Tax Type", GetFilter("Tax Type"));
    end;
}