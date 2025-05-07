namespace Microsoft.SubscriptionBilling;

report 8002 "Cr. Serv. Comm. And Contr. L."
{
    ApplicationArea = All;
    UsageCategory = None;
    ProcessingOnly = true;
    Caption = 'Create Subscription Lines and Subscription Contract Lines';

    dataset
    {
        dataitem(ImportedServiceCommitmentDataItem; "Imported Subscription Line")
        {
            trigger OnPreDataItem()
            begin
                NoOfRecords := Count;
                Counter := 0;
            end;

            trigger OnAfterGetRecord()
            var
                ImportedSubscriptionLine: Record "Imported Subscription Line";
                SkipCreateContractLine: Boolean;
            begin
                Counter += 1;

                if ImportedServiceCommitmentDataItem."Subscription Line created" and ImportedSubscriptionLine."Sub. Contract Line created" then
                    CurrReport.Skip();

                if (Counter mod 10 = 0) or (Counter = NoOfRecords) then
                    Window.Update(1, Round(Counter / NoOfRecords * 10000, 1));

                ImportedSubscriptionLine := ImportedServiceCommitmentDataItem;
                ImportedSubscriptionLine."Error Text" := '';

                if not ImportedSubscriptionLine."Subscription Line created" then begin
                    ClearLastError();
                    if not Codeunit.Run(Codeunit::"Create Subscription Line", ImportedSubscriptionLine) then begin
                        ImportedSubscriptionLine."Error Text" := CopyStr(GetLastErrorText, 1, MaxStrLen(ImportedSubscriptionLine."Error Text"));
                        ImportedSubscriptionLine.Modify(false);
                        SkipCreateContractLine := true;
                    end;
                    Commit(); //retain data even if errors ocurr
                end;

                OnAfterCreateSubscriptionLineOnBeforeCreateContractLine(ImportedSubscriptionLine, SkipCreateContractLine);

                if (not ImportedSubscriptionLine."Sub. Contract Line created") and (not SkipCreateContractLine) then begin
                    ClearLastError();
                    if not Codeunit.Run(Codeunit::"Create Sub. Contract Line", ImportedSubscriptionLine) then begin
                        ImportedSubscriptionLine."Error Text" := CopyStr(GetLastErrorText, 1, MaxStrLen(ImportedSubscriptionLine."Error Text"));
                        ImportedSubscriptionLine.Modify(false);
                    end;
                    Commit(); //retain data even if errors ocurr
                end;
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    trigger OnPostReport()
    begin
        Window.Close();
        Message(ProcessingFinishedMsg);
    end;

    trigger OnPreReport()
    begin
        Window.Open(ImportWindowTxt);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateSubscriptionLineOnBeforeCreateContractLine(ImportedServiceCommitment: Record "Imported Subscription Line"; var SkipCreateContractLine: Boolean)
    begin
    end;

    var
        Window: Dialog;
        NoOfRecords: Integer;
        Counter: Integer;
        ImportWindowTxt: Label 'Processing Records ...\\@1@@@@@@@@@@@@@@';
        ProcessingFinishedMsg: Label 'Processing finished.';
}