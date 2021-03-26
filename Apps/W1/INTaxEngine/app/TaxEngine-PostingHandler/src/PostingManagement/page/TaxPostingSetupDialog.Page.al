page 20336 "Tax Posting Setup Dialog"
{
    PageType = ListPart;
    SourceTable = "Tax Posting Setup";
    RefreshOnActivate = true;
    PopulateAllFields = true;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Name; ComponentName)
                {
                    Caption = 'Component';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the component name for G/L Account mapping.';
                    trigger OnValidate();
                    begin
                        ScriptSymbolsMgmt.SearchSymbol(
                            "Symbol Type"::Component,
                            "Component ID",
                            ComponentName);
                        Validate("Component ID");
                    end;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        ScriptSymbolsMgmt.OpenSymbolsLookup(
                            "Symbol Type"::Component,
                            Text,
                            "Component ID",
                            ComponentName);
                        Validate("Component ID");
                    end;
                }
                field("Account Source Type"; "Account Source Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source type of G/L Account for a component.';
                    trigger OnValidate()
                    var
                        FieldNameValue: Text[30];
                    begin
                        if "Account Source Type" <> "Account Source Type"::Field then begin
                            FieldNameTxt := '';

                            AppObjectHelper.SearchTableFieldOfType("Table ID", "Field ID", FieldNameValue, "Symbol Data Type"::STRING);

                            FieldNameTxt := FieldNameValue;
                        end;
                        FormatLine();
                    end;
                }
                field(FieldName; FieldNameTxt)
                {
                    Caption = 'Field Name';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the field name for G/L Account mapping.';
                    trigger OnValidate()
                    var
                        FieldValue: Text[30];
                    begin
                        if "Account Source Type" = "Account Source Type"::Field then begin
                            FieldValue := CopyStr(FieldNameTxt, 1, 30);
                            AppObjectHelper.SearchTableFieldOfType(
                                "Table ID",
                                "Field ID",
                                FieldValue,
                                "Symbol Data Type"::STRING);

                            FieldNameTxt := FieldValue;
                        end else
                            Error(InvalidManualLookupErr);
                    end;

                    trigger OnAssistEdit();
                    var
                        LookupMgmt: Codeunit "Lookup Mgmt.";
                        Datatype: Enum "Symbol Data Type";
                        FieldValue: Text[30];
                    begin
                        if "Account Source Type" = "Account Source Type"::Lookup then begin
                            if IsNullGuid("Account Lookup ID") then
                                "Account Lookup ID" := LookupEntityMgmt.CreateLookup("Case ID", EmptyGuid);

                            CurrPage.SaveRecord();
                            Commit();

                            LookupMgmt.OpenLookupDialogOfType(
                                "Case ID",
                                EmptyGuid,
                                "Account Lookup ID",
                                Datatype::STRING);

                            Validate("Account Lookup ID");
                        end else begin
                            FieldValue := CopyStr(FieldNameTxt, 1, 30);
                            AppObjectHelper.OpenFieldLookupOfType(
                            "Table ID",
                            "Field ID",
                            FieldValue,
                            FieldNameTxt,
                            "Symbol Data Type"::STRING);

                            FieldNameTxt := FieldValue;
                        end;
                        FormatLine();
                    end;
                }
                field("Accounting Impact"; "Accounting Impact")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Accounting Impact for G/L Account mapping. whether it will be Debit or Credit.';
                }
                field("Reverse Charge"; "Reverse Charge")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether posting is setup for Reverse Charge.';
                    trigger OnValidate()
                    begin
                        FormatLine();
                    end;
                }
                field("Reversal Account Source Type"; "Reversal Account Source Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source type of Reversal G/L Account for a component.';
                    trigger OnValidate()
                    var
                        TaxUseCase: Record "Tax Use Case";
                        ReversalFieldNameValue: Text[30];
                    begin
                        if "Reversal Account Source Type" = "Reversal Account Source Type"::Field then begin
                            if not IsNullGuid("Reversal Account Lookup ID") then begin
                                TaxUseCase.Get("Case ID");
                                LookupEntityMgmt.DeleteLookup("Case ID", TaxUseCase."Posting Script ID", "Reversal Account Lookup ID");
                            end;
                        end else begin
                            ReversalFieldNameTxt := '';

                            AppObjectHelper.SearchTableFieldOfType(
                            "Table ID",
                            "Reverse Charge Field ID",
                            ReversalFieldNameValue,
                            "Symbol Data Type"::STRING);
                        end;
                        ReversalFieldNameTxt := ReversalFieldNameValue;
                        FormatLine();
                    end;
                }
                field(ReversalFieldName; ReversalFieldNameTxt)
                {
                    Caption = 'Reverse Charge G/L Field Name';
                    ToolTip = 'Specifies mapping of Reverse Charge GL Account.';
                    ApplicationArea = Basic, Suite;
                    Editable = "Reverse Charge";
                    trigger OnAssistEdit();
                    var
                        LookupMgmt: Codeunit "Lookup Mgmt.";
                        Datatype: Enum "Symbol Data Type";
                        ReversalFieldNameValue: Text[30];
                    begin
                        if "Reversal Account Source Type" = "Reversal Account Source Type"::Lookup then begin
                            if IsNullGuid("Reversal Account Lookup ID") then
                                Validate("Reversal Account Lookup ID", LookupEntityMgmt.CreateLookup("Case ID", EmptyGuid));

                            CurrPage.SaveRecord();
                            Commit();

                            LookupMgmt.OpenLookupDialogOfType(
                                "Case ID",
                                EmptyGuid,
                                "Reversal Account Lookup ID",
                                Datatype::STRING);

                            Validate("Reversal Account Lookup ID");
                        end else begin
                            ReversalFieldNameValue := copystr(ReversalFieldNameTxt, 1, 30);
                            AppObjectHelper.OpenFieldLookupOfType(
                            "Table ID",
                            "Reverse Charge Field ID",
                            ReversalFieldNameValue,
                            ReversalFieldNameTxt,
                            "Symbol Data Type"::STRING);
                            ReversalFieldNameTxt := ReversalFieldNameValue;
                            Validate("Reverse Charge Field ID");
                        end;
                        FormatLine();
                    end;
                }
                field(TaxPostingFilters; PostingTableFilters)
                {
                    Caption = 'Posting Table Filters';
                    ToolTip = 'Specifies the table filters applied on posting setup table in addition to filters applied on header.';
                    ApplicationArea = Basic, Suite;
                    Editable = false;

                    trigger OnAssistEdit()
                    begin
                        if IsNullGuid("Table Filter ID") then begin
                            "Table Filter ID" := LookupEntityMgmt.CreateTableFilters(
                                "Case ID",
                                EmptyGuid,
                                "Table ID");
                            CurrPage.Update(true);
                            Commit();
                        end;
                        LookupDialogMgmt.OpenTableFilterDialog("Case ID", EmptyGuid, "Table Filter ID");
                    end;
                }
                field(SubLedgerMapping; WhenConditionTxt)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Tax Ledger Mapping';
                    Editable = false;
                    ToolTip = 'Specifies the mapping of Insert Record in tax Ledger.';
                    trigger OnDrillDown()
                    begin
                        if IsNullGuid("Switch Statement ID") then
                            "Switch Statement ID" := SwitchStatementHelper.CreateSwitchStatement("Case ID");

                        SwitchStatementHelper.OpenSwitchStatements("Case ID", "Switch Statement ID", "Switch Case Action Type"::"Insert Record");
                    end;
                }
            }
        }
    }


    trigger OnAfterGetRecord()
    begin
        ScriptSymbolsMgmt.SetContext("Case ID", EmptyGuid);
        FormatLine();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        ScriptSymbolsMgmt.SetContext("Case ID", EmptyGuid);
        FormatLine();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ComponentName := '';
    end;

    local procedure FormatLine()
    var
        UseCase: Record "Tax Use Case";
        SwtichCase: Record "Switch Case";
    begin
        if not UseCase.Get("Case ID") then
            exit;
        if "Component ID" <> 0 then
            ComponentName := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::Component, "Component ID")
        else
            ComponentName := '';

        if ("Field ID" <> 0) and ("Account Source Type" = "Account Source Type"::Field) then
            FieldNameTxt := AppObjectHelper.GetFieldName("Table ID", "Field ID")
        else
            FieldNameTxt := '';

        if "Account Source Type" = "Account Source Type"::Lookup then
            FieldNameTxt := LookupSerialization.LookupToString(
                "Case ID",
                EmptyGuid,
                "Account Lookup ID");

        if ("Reverse Charge Field ID" <> 0) and ("Reversal Account Source Type" = "Reversal Account Source Type"::Field) then
            ReversalFieldNameTxt := AppObjectHelper.GetFieldName("Table ID", "Reverse Charge Field ID")
        else
            ReversalFieldNameTxt := '';

        if "Reversal Account Source Type" = "Reversal Account Source Type"::Lookup then
            ReversalFieldNameTxt := LookupSerialization.LookupToString(
                "Case ID",
                EmptyGuid,
                "Reversal Account Lookup ID");

        if not IsNullGuid("Switch Statement ID") then begin
            WhenConditionTxt := '';
            Clear(WhenConditionTxt);
            SwtichCase.SetRange("Case ID", "Case ID");
            SwtichCase.SetRange("Switch Statement ID", "Switch Statement ID");
            if SwtichCase.FindSet() then
                repeat
                    if WhenConditionTxt <> '' then
                        WhenConditionTxt += ', ';

                    if not IsNullGuid(SwtichCase."Condition ID") then
                        WhenConditionTxt +=
                            'If ' +
                            ScriptSerialization.ConditionToString(
                                "Case ID",
                                EmptyGuid,
                                SwtichCase."Condition ID") +
                            ' Then ';

                    if not IsNullGuid(SwtichCase."Action ID") then
                        WhenConditionTxt +=
                            TaxPostingSerialization.InsertRecordToString(
                                "Case ID",
                                UseCase."Posting Script ID",
                                SwtichCase."Action ID");
                until SwtichCase.Next() = 0
            else
                WhenConditionTxt := '< Subledger Mapping >';
        end;

        if not IsNullGuid("Table Filter ID") then
            PostingTableFilters := LookupSerialization.TableFilterToString(
                "Case ID",
                EmptyGuid,
                "Table Filter ID")
        else
            PostingTableFilters := '<Table Filters>';
    end;


    var
        AppObjectHelper: Codeunit "App Object Helper";
        TaxPostingSerialization: Codeunit "Tax Posting Helper";
        ScriptSerialization: Codeunit "Script Serialization";
        LookupSerialization: Codeunit "Lookup Serialization";
        SwitchStatementHelper: Codeunit "Switch Statement Helper";
        LookupDialogMgmt: Codeunit "Lookup Dialog Mgmt.";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
        EmptyGuid: Guid;
        ComponentName: Text[30];
        PostingTableFilters: Text;
        FieldNameTxt: Text;
        ReversalFieldNameTxt: Text;
        WhenConditionTxt: Text;
        InvalidManualLookupErr: Label 'You cannot enter lookup value manually for source type Lookup.';
}