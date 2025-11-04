/// <summary>
/// Provides handler functions for managing dialog messages and prompts in automated test scenarios.
/// </summary>
codeunit 131005 "Library - Dialog Handler"
{
    var
        Assert: Codeunit Assert;
        LibraryVariableStorage: Codeunit "Library - Variable Storage";

    procedure HandleMessage(Message: Text)
    begin
        Assert.ExpectedMessage(LibraryVariableStorage.DequeueText(), Message);
    end;

    procedure HandleConfirm(Question: Text; var Reply: Boolean)
    begin
        Assert.ExpectedConfirm(LibraryVariableStorage.DequeueText(), Question);
        Reply := LibraryVariableStorage.DequeueBoolean();
    end;

    procedure HandleStrMenu(Options: Text; var Choice: Integer; Instruction: Text)
    begin
        Assert.ExpectedStrMenu(
            LibraryVariableStorage.DequeueText(), LibraryVariableStorage.DequeueText(),
            Instruction, Options);
        Choice := LibraryVariableStorage.DequeueInteger();
    end;

    procedure SetExpectedMessage(Message: Text)
    begin
        LibraryVariableStorage.Enqueue(Message);
    end;

    procedure SetExpectedConfirm(Question: Text; Reply: Boolean)
    begin
        LibraryVariableStorage.Enqueue(Question);
        LibraryVariableStorage.Enqueue(Reply);
    end;

    procedure SetExpectedStrMenu(Options: Text; Choice: Integer; Instruction: Text)
    begin
        LibraryVariableStorage.Enqueue(Instruction);
        LibraryVariableStorage.Enqueue(Options);
        LibraryVariableStorage.Enqueue(Choice);
    end;

    procedure ClearVariableStorage()
    begin
        LibraryVariableStorage.Clear();
    end;
}