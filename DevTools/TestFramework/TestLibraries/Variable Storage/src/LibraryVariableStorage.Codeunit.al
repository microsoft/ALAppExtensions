// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Library - Variable Storage" provides functions that pass values from test methods to page and message handler methods that are called out of context and cannot be called directly.
/// This provides a flexible way to store values when running tests because you do not need to have specific global variables for each scenario.
/// </summary>
codeunit 131004 "Library - Variable Storage"
{
    var
        Assert: Codeunit "Library Assert";
        Variables: array[25] of Variant;
        EndIndex: Integer;
        StartIndex: Integer;
        AssertEmptyErr: Label 'Queue is not empty.';
        AssertFullErr: Label 'Queue is empty.';
        TotalCount: Integer;
        OverflowErr: Label 'Queue overflow.';
        UnderflowErr: Label 'Queue underflow.';
        OutOfBoundsErr: Label 'Index out of bounds.';

    /// <summary>
    /// Displays an error if the queue is not empty.
    /// </summary>
    procedure AssertEmpty()
    var
        PreviousCount: Integer;
    begin
        PreviousCount := TotalCount;
        if TotalCount <> 0 then begin
            ClearQueue();
            Assert.AreEqual(0, PreviousCount, AssertEmptyErr);
        end;
    end;

    /// <summary>
    /// Displays an error if the queue is full.
    /// </summary>
    procedure AssertFull()
    begin
        Assert.AreEqual(MaxLength(), TotalCount, AssertFullErr);
    end;

    /// <summary>
    /// Displays an error if adding a value to the queue will cause an overflow.
    /// </summary>
    procedure AssertNotOverflow()
    begin
        Assert.IsFalse(TotalCount + 1 > MaxLength(), OverflowErr);
    end;

    /// <summary>
    /// Displays an error if there are fewer than zero values in the queue.
    /// </summary>
    procedure AssertNotUnderflow()
    begin
        Assert.IsTrue(TotalCount > 0, UnderflowErr);
    end;

    /// <summary>
    /// Indicates whether you can peek at the value in the queue at the given index without dequeing the value. Displays an error if there is a value in the queue at the given index.
    /// </summary>
    /// <param name="Index">The position in the queue to test.</param>
    procedure AssertPeekAvailable(Index: Integer)
    begin
        Assert.IsTrue(Index > 0, OutOfBoundsErr);
        Assert.IsTrue(Index <= TotalCount, OutOfBoundsErr);
    end;

    /// <summary>
    /// Removes all values from the queue.
    /// </summary>
    procedure Clear()
    begin
        // For internal calls we need ClearQueue because Clear is a reserved keyword for CAL.
        ClearQueue();
    end;

    local procedure ClearQueue()
    begin
        StartIndex := 0;
        EndIndex := 0;
        TotalCount := 0;
    end;

    /// <summary>
    /// Reads the top value from the queue and removes it.
    /// </summary>
    /// <param name="Variable">Returns the top value read from the queue. </param>
    procedure Dequeue(var Variable: Variant)
    begin
        StartIndex := (StartIndex mod MaxLength()) + 1;
        AssertNotUnderflow();
        Variable := Variables[StartIndex];
        TotalCount -= 1;
    end;

    /// <summary>
    /// Returns the value from a given index in the queue without dequeuing the value.
    /// </summary>
    /// <param name="Variable">Returns the value that is stored in the queue.</param>
    /// <param name="Index">The position in the queue from which the value will be read.</param>
    procedure Peek(var Variable: Variant; Index: Integer)
    begin
        AssertPeekAvailable(Index);
        Variable := Variables[((StartIndex + (Index - 1)) mod MaxLength()) + 1];
    end;

    /// <summary>
    /// Store one value in to the queue.
    /// </summary>
    /// <param name="Variable">The value to add to the queue.</param>
    procedure Enqueue(Variable: Variant)
    begin
        EndIndex := (EndIndex mod MaxLength()) + 1;
        AssertNotOverflow();
        Variables[EndIndex] := Variable;
        TotalCount += 1;
    end;

    /// <summary>
    /// Returns the length of the queue.
    /// </summary>
    procedure Length(): Integer
    begin
        exit(TotalCount);
    end;

    /// <summary>
    /// Returns the maximum length of the queue.
    /// </summary>
    procedure MaxLength(): Integer
    begin
        exit(ArrayLen(Variables));
    end;

    /// <summary>
    /// Reads one value of type Text from the queue and removes it. If the type of the value is not Text an error is displayed.
    /// </summary>
    procedure DequeueText(): Text
    var
        ExpectedValue: Variant;
    begin
        Dequeue(ExpectedValue);
        exit(Format(ExpectedValue));
    end;

    /// <summary>
    /// Reads one value of type Decimal from the queue and removes it. If the type of the value is not Decimal an error is displayed.
    /// </summary>
    procedure DequeueDecimal(): Decimal
    var
        ExpectedValue: Variant;
    begin
        Dequeue(ExpectedValue);
        exit(ExpectedValue);
    end;

    /// <summary>
    /// Reads one value of type Integer from the queue and removes it. If the type of the value is not Integer an error is displayed.
    /// </summary>
    procedure DequeueInteger(): Integer
    var
        ExpectedValue: Variant;
    begin
        Dequeue(ExpectedValue);
        exit(ExpectedValue);
    end;

    /// <summary>
    /// Reads one value of type Date from the queue and removes it. If the type of the value is not Date an error is displayed.
    /// </summary>
    procedure DequeueDate(): Date
    var
        ExpectedValue: Variant;
    begin
        Dequeue(ExpectedValue);
        exit(ExpectedValue);
    end;

    /// <summary>
    /// Reads one value of type DateTime from the queue and removes it. If the type of the value is not DateTime an error is displayed.
    /// </summary>
    procedure DequeueDateTime(): DateTime
    var
        ExpectedValue: Variant;
    begin
        Dequeue(ExpectedValue);
        exit(ExpectedValue);
    end;

    /// <summary>
    /// Reads one value of type Time from the queue and removes it. If the type of the value is not Time an error is displayed.
    /// </summary>
    procedure DequeueTime(): Time
    var
        ExpectedValue: Variant;
    begin
        Dequeue(ExpectedValue);
        exit(ExpectedValue);
    end;

    /// <summary>
    /// Reads one value of type Boolean from the queue and removes it. If the type of the value is not Boolean an error is displayed.
    /// </summary>
    procedure DequeueBoolean(): Boolean
    var
        ExpectedValue: Variant;
    begin
        Dequeue(ExpectedValue);
        exit(ExpectedValue);
    end;

    /// <summary>
    /// Returns a value of type Text at the given position in the queue without dequeuing the value. If the type of the value is not Text an error is displayed.
    /// </summary>
    /// <param name="Index">The position in the queue from which the value will be read.</param>
    procedure PeekText(Index: Integer): Text
    var
        ExpectedValue: Variant;
    begin
        Peek(ExpectedValue, Index);
        exit(Format(ExpectedValue));
    end;

    /// <summary>
    /// Returns a value of type Decimal at the given position in the queue without dequeuing the value. If the type of the value is not Decimal an error is displayed.
    /// </summary>
    /// <param name="Index">The position in the queue from which the value will be read.</param>
    procedure PeekDecimal(Index: Integer): Decimal
    var
        ExpectedValue: Variant;
    begin
        Peek(ExpectedValue, Index);
        exit(ExpectedValue);
    end;

    /// <summary>
    /// Returns a value of type Integer at the given position in the queue without dequeuing the value. If the type of the value is not Integer an error is displayed.
    /// </summary>
    /// <param name="Index">The position in the queue from which the value will be read.</param>
    procedure PeekInteger(Index: Integer): Integer
    var
        ExpectedValue: Variant;
    begin
        Peek(ExpectedValue, Index);
        exit(ExpectedValue);
    end;

    /// <summary>
    /// Returns a value of type Date at the given position in the queue without dequeuing the value. If the type of the value is not Date an error is displayed.
    /// </summary>
    /// <param name="Index">The position in the queue from which the value will be read.</param>
    procedure PeekDate(Index: Integer): Date
    var
        ExpectedValue: Variant;
    begin
        Peek(ExpectedValue, Index);
        exit(ExpectedValue);
    end;

    /// <summary>
    /// Returns a value of type Time at the given position in the queue without dequeuing the value. If the type of the value is not Time an error is displayed.
    /// </summary>
    /// <param name="Index">The position in the queue from which the value will be read.</param>
    procedure PeekTime(Index: Integer): Time
    var
        ExpectedValue: Variant;
    begin
        Peek(ExpectedValue, Index);
        exit(ExpectedValue);
    end;

    /// <summary>
    /// Returns a value of type Boolean at the given position in the queue without deaueuing the value. If the type of the value is not Boolean an error is displayed.
    /// </summary>
    /// <param name="Index">The position in the queue from which the value will be read.</param>
    procedure PeekBoolean(Index: Integer): Boolean
    var
        ExpectedValue: Variant;
    begin
        Peek(ExpectedValue, Index);
        exit(ExpectedValue);
    end;
}

