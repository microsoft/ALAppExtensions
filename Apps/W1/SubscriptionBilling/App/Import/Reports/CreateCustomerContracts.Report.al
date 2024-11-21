namespace Microsoft.SubscriptionBilling;

report 8003 "Create Customer Contracts"
{
    ApplicationArea = All;
    UsageCategory = None;
    ProcessingOnly = true;
    Caption = 'Create Customer Contracts';

    dataset
    {
        dataitem(ImportedCustomerContractDataItem; "Imported Customer Contract")
        {
            DataItemTableView = where("Contract created" = const(false));

            trigger OnPreDataItem()
            begin
                NoOfRecords := Count;
                Counter := 0;
            end;

            trigger OnAfterGetRecord()
            begin
                Counter += 1;

                if (Counter mod 10 = 0) or (Counter = NoOfRecords) then
                    Window.Update(1, Round(Counter / NoOfRecords * 10000, 1));

                ClearLastError();
                ImportedCustomerContract := ImportedCustomerContractDataItem;
                if not Codeunit.Run(Codeunit::"Create Customer Contract", ImportedCustomerContract) then begin
                    ImportedCustomerContract."Error Text" := CopyStr(GetLastErrorText, 1, MaxStrLen(ImportedCustomerContract."Error Text"));
                    ImportedCustomerContract.Modify(false);
                end;

                Commit(); //retain data even if errors ocurr
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

    var
        ImportedCustomerContract: Record "Imported Customer Contract";
        Window: Dialog;
        NoOfRecords: Integer;
        Counter: Integer;
        ImportWindowTxt: Label 'Processing Records ...\\@1@@@@@@@@@@@@@@';
        ProcessingFinishedMsg: Label 'Processing finished.';
}