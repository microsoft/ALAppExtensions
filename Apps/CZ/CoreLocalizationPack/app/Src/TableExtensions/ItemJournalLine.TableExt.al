tableextension 11709 "Item Journal Line CZL" extends "Item Journal Line"
{
    fields
    {
        field(31079; "Invt. Movement Template CZL"; Code[10])
        {
            Caption = 'Inventory Movement Template';
            TableRelation = "Invt. Movement Template CZL";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                InvtMovementTemplateCZL: Record "Invt. Movement Template CZL";
                ItemJournalTemplate: Record "Item Journal Template";
            begin
                if InvtMovementTemplateCZL.Get("Invt. Movement Template CZL") then begin
                    ItemJournalTemplate.Get("Journal Template Name");
                    case ItemJournalTemplate.Type of
                        ItemJournalTemplate.Type::Transfer:
                            InvtMovementTemplateCZL.TestField("Entry Type", InvtMovementTemplateCZL."Entry Type"::Transfer);
                        ItemJournalTemplate.Type::"Phys. Inventory":
                            if CurrFieldNo = FieldNo("Invt. Movement Template CZL") then
                                InvtMovementTemplateCZL.TestField("Entry Type", "Entry Type");
                    end;
                    if ItemJournalTemplate.Type <> ItemJournalTemplate.Type::"Phys. Inventory" then
                        Validate("Entry Type", InvtMovementTemplateCZL."Entry Type");
                    Validate("Gen. Bus. Posting Group", InvtMovementTemplateCZL."Gen. Bus. Posting Group");
                end;
            end;
        }
    }
}
