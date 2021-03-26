page 20337 "Use Case Posting"
{
    PageType = Card;
    SourceTable = "Tax Use Case";
    DataCaptionExpression = Description;
    RefreshOnActivate = true;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                Caption = 'General';
                field(TaxPostingEntity; PostingTableName)
                {
                    Caption = 'Posting Entity Name';
                    ToolTip = 'Specifies the table that will be used for getting posting GL accounts for the Components.';
                    ApplicationArea = Basic, Suite;
                    trigger OnValidate()
                    begin
                        AppObjectHelper.SearchObject(ObjectType::Table, "Posting Table ID", PostingTableName);
                        Validate("Posting Table ID");
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        AppObjectHelper.OpenObjectLookup(ObjectType::Table, Text, "Posting Table ID", PostingTableName);
                        Validate("Posting Table ID");
                    end;
                }
                field(TaxPostingFilters; PostingTableFilters)
                {
                    Caption = 'Posting Table Filters';
                    ToolTip = 'Specifies the filter that will be applied on posting table for getting posting GL accounts for the Components.';
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    trigger OnAssistEdit()
                    var

                    begin
                        if IsNullGuid("Posting Table Filter ID") then begin
                            "Posting Table Filter ID" := LookupEntityMgmt.CreateTableFilters(ID, EmptyGuid, "Posting Table ID");
                            CurrPage.Update(true);
                            Commit();
                        end;
                        LookupDialogMgmt.OpenTableFilterDialog(ID, EmptyGuid, "Posting Table Filter ID");
                    end;
                }
            }
            part(Posting; "Tax Posting Setup Dialog")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Case ID" = field(ID), "Table ID" = field("Posting Table ID");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(PostingScript)
            {
                Caption = 'Posting Script';
                ToolTip = 'Opens script editor to write computation logic(if any).';
                ApplicationArea = Basic, Suite;
                Image = PostDocument;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = page "Script Context";
                RunPageLink = "Case ID" = field(ID), ID = field("Posting Script ID");
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        FormatLine();
    end;

    trigger OnAfterGetRecord()
    begin
        FormatLine();
    end;

    local procedure FormatLine()
    begin
        if not IsNullGuid("Posting Table Filter ID") then
            PostingTableFilters := LookupSerialization.TableFilterToString(ID, EmptyGuid, "Posting Table Filter ID")
        else
            PostingTableFilters := '<Table Filters>';

        if "Posting Table ID" <> 0 then
            PostingTableName := AppObjectHelper.GetObjectName(ObjectType::Table, "Posting Table ID")
        else
            PostingTableName := '';

    end;

    var
        LookupSerialization: Codeunit "Lookup Serialization";
        LookupDialogMgmt: Codeunit "Lookup Dialog Mgmt.";
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
        AppObjectHelper: Codeunit "App Object Helper";
        PostingTableName: Text[30];
        PostingTableFilters: Text;
        EmptyGuid: Guid;

}