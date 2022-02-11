codeunit 20369 "Archival Single Instance"
{
    SingleInstance = true;

    procedure SetSkipTaxAttributeDeletion(NewSkipTaxAttribute: Boolean)
    begin
        SkipTaxAttribute := NewSkipTaxAttribute;
    end;

    procedure GetSkipTaxAttribute(): Boolean
    begin
        exit(SkipTaxAttribute);
    end;

    procedure SetSkipTaxComponentDeletion(NewSkipTaxComponent: Boolean)
    begin
        SkipTaxComponent := NewSkipTaxComponent;
    end;

    procedure GetSkipTaxComponent(): Boolean
    begin
        exit(SkipTaxComponent);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Tax Types", 'OnOpenPageEvent', '', false, false)]
    local procedure TaxTypesOnOpenPage()
    begin
        Clear(SkipTaxAttribute);
        Clear(SkipTaxComponent);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Tax Types", 'OnAfterActionEvent', 'ArchivedLogs', false, false)]
    local procedure OnAfterActionTaxTypesArchivedLogs()
    begin
        Clear(SkipTaxAttribute);
        Clear(SkipTaxComponent);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Tax Type", 'OnAfterActionEvent', 'ArchivedLogs', false, false)]
    local procedure OnAfterActionTaxTypeArchivedLogs()
    begin
        Clear(SkipTaxAttribute);
        Clear(SkipTaxComponent);
    end;

    var
        SkipTaxAttribute: Boolean;
        SkipTaxComponent: Boolean;
}