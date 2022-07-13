codeunit 50100 "DataTable Test"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Assert: Codeunit "Library Assert";
        DataTable: Codeunit DataTable;
        Expression: Text;

    [Test]
    procedure SimpleBooleanTest()
    var
        Result: Boolean;
    begin
        Expression := 'true = false';
        Result := DataTable.Calculate(Expression);

        Assert.IsFalse(Result, '');
    end;

    [Test]
    procedure ComplexBooleanExpressionTest()
    var
        Result: Boolean;
    begin
        Expression := '(3 < (2 * 1 / 2)) and (4 >= (3 / 1))';
        Result := DataTable.Calculate(Expression);

        Assert.IsFalse(Result, '');
    end;

    [Test]
    procedure ComplexBooleanExpressionTest2()
    var
        Result: Boolean;
    begin
        Expression := '(3 < (2*3)) and (4 >= (3 / 1))';
        Result := DataTable.Calculate(Expression);

        Assert.IsTrue(Result, '');
    end;

    [Test]
    procedure ComplexBooleanExpressionTest3()
    var
        Result: Boolean;
    begin
        Expression := '(3 < 4) and (4 >= 3)';
        Result := DataTable.Calculate(Expression);

        Assert.IsTrue(Result, '');
    end;

    [Test]
    procedure IntegerExpressionTest()
    var
        Result: Integer;
    begin
        Expression := '1000 + 1 - 20';
        Result := DataTable.Calculate(Expression);

        Assert.AreEqual(981, Result, '');
    end;

    [Test]
    procedure BigIntegerExpressionTest()
    var
        Result: BigInteger;
    begin
        Expression := '2147483647 * 2';
        Result := DataTable.Calculate(Expression);

        Assert.AreEqual(4294967296L, Result, '');
    end;

    [Test]
    procedure DecimalExpressionTest()
    var
        Result: Decimal;
    begin
        Expression := '3 * 29.15 * (400 / 125)';
        Result := DataTable.Calculate(Expression);

        Assert.AreEqual(279.84, Result, '');
    end;

    [Test]
    procedure DivideByZeroTest()
    var
        Result: Decimal;
    begin
        Expression := '3 * 29.5 * (400 / 0)';
        Result := DataTable.Calculate(Expression);

        Assert.AreEqual(0, Result, '');
        Assert.ExpectedError('Attempted to divide by zero.');
    end;

    [Test]
    procedure TryDivideByZeroTest()
    var
        Result: Variant;
        Success: Boolean;
    begin
        Expression := '3 * 29.5 * (400 / 0)';
        Success := DataTable.Calculate(Expression, Result);

        Assert.IsFalse(Success, '');
        Assert.ExpectedError('Attempted to divide by zero.');
    end;

    [Test]
    procedure DecimalOutOfRangeTest()
    var
        Result: BigInteger;
    begin
        Expression := '300000000000000000000000000000 * 29.5 * (400 / 100)';
        Result := DataTable.Calculate(Expression);

        Assert.AreEqual(0L, Result, '');
        Assert.ExpectedError('Value was either too large or too small for a Decimal.');
    end;

    [Test]
    procedure TryDecimalOutOfRangeTest()
    var
        Result: BigInteger;
    begin
        Expression := '300000000000000000000000000000 * 29.5 * (400 / 100)';
        Result := DataTable.Calculate(Expression);

        Assert.ExpectedError('Value was either too large or too small for a Decimal.');
    end;

    [Test]
    procedure InvalidExpressionTest()
    var
        ResultVariant: Decimal;
    begin
        Expression := '123,456 * 789';
        ResultVariant := DataTable.Calculate(Expression);

        Assert.AreEqual(0, ResultVariant, '');
        Assert.ExpectedError('A call to System.Data.DataTable.Compute failed with this message: Syntax error in the expression.');
    end;

    [Test]
    procedure TryInvalidExpressionTest()
    var
        Success: Boolean;
        ResultVariant: Variant;
    begin
        Expression := '123,456 * 789';
        Success := DataTable.Calculate(Expression, ResultVariant);

        Assert.IsFalse(Success, '');
        Assert.ExpectedError('A call to System.Data.DataTable.Compute failed with this message: Syntax error in the expression.');
    end;
}