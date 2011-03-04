namespace ROEcmaScript.Test;

interface

uses
  System,
  System.IO,
  System.Collections.Generic,
  System.Linq,
  System.Text,
  Xunit.Sdk;
  
type
  [Xunit.RunWith(typeof(SputnikTests))]
  SputnikTest = public class(Xunit.Sdk.ITestCommand, Xunit.Sdk.IMethodInfo)
  private
  public
    property Owner: SputnikTests;
    property Name: string;

    property TypeName: System.String read 'ROEcmaScript.Test.SputnikTest';
    property ReturnType: System.String read 'System.Void';
    property MethodInfo: System.Reflection.MethodInfo read typeof(SputnikTest).GetMethod('Run');
    property IsStatic: System.Boolean read false;
    property IsAbstract: System.Boolean read false;
    method Invoke(testClass: System.Object; params parameters: array of System.Object); empty;
    method HasAttribute(attributeType: System.Type): System.Boolean; empty;
    method GetCustomAttributes(attributeType: System.Type): sequence of Xunit.Sdk.IAttributeInfo;
    method CreateInstance: System.Object; empty;
    method ToStartXml: System.Xml.XmlNode; empty;
    property Timeout: System.Int32 read 60000;
    property ShouldCreateInstance: System.Boolean read false;
    method Execute(testClass: System.Object): Xunit.Sdk.MethodResult;
    property DisplayName: System.String read Name;
    method GetHashCode: Int32; override;
    method Equals(obj: Object): Boolean; override;

    method Run(Data: SputnikTest);
  end;

  SputnikException = public class(Exception)

  private
  public
    method ToString: String; override;
  end;

  SputnikTests = public class(ITestClassCommand)
  private
    fTests: List<SputnikTest> := new List<SputnikTest>;
    fLib: string;
    fSputnikRoot: string;
    fTestRoot: string;
    fFramework: string;
    class var fInclude: System.Text.RegularExpressions.Regex := new System.Text.RegularExpressions.Regex('\$INCLUDE\(\"(.*)\"\);');
    class var fSpecialCall: System.Text.RegularExpressions.Regex := new System.Text.RegularExpressions.Regex('\$([A-Z]+)(?=\()');
    method ScanJS(aScan: String);
  public
    constructor;


    method Include(arg: System.Text.RegularExpressions.Match): string;
    method RunTest(aName: string);
    method SpecialCall(aMatch: System.Text.RegularExpressions.Match): string;
    property TypeUnderTest: Xunit.Sdk.ITypeInfo;
    property ObjectUnderTest: System.Object read nil;
    method IsTestMethod(testMethod: Xunit.Sdk.IMethodInfo): System.Boolean;
    method EnumerateTestMethods: sequence of Xunit.Sdk.IMethodInfo;
    method EnumerateTestCommands(testMethod: Xunit.Sdk.IMethodInfo): sequence of Xunit.Sdk.ITestCommand;
    method ClassStart: System.Exception; empty;
    method ClassFinish: System.Exception;empty;
    method ChooseNextTest(testsLeftToRun: System.Collections.Generic.ICollection<Xunit.Sdk.IMethodInfo>): System.Int32;empty;
  end;
  
implementation

method SputnikTests.IsTestMethod(testMethod: Xunit.Sdk.IMethodInfo): System.Boolean;
begin
  exit true;
end;

method SputnikTests.EnumerateTestMethods: sequence of Xunit.Sdk.IMethodInfo;
begin
  exit fTests.Cast<Xunit.Sdk.IMethodInfo>();
end;

method SputnikTests.EnumerateTestCommands(testMethod: Xunit.Sdk.IMethodInfo): sequence of Xunit.Sdk.ITestCommand;
begin
  exit [testMethod as Xunit.Sdk.ITestCommand];
end;

constructor SputnikTests;
begin
  var lPath := new Uri(typeOf(SputnikTests).Assembly.EscapedCodeBase).LocalPath;
  
  fSputnikRoot := Path.GetFullPath(Path.Combine(Path.Combine(Path.Combine(Path.GetDirectoryName(lPath), '..'), 'Test'), 'sputniktests'));
  fTestRoot := Path.Combine(fSputnikRoot, 'tests');
  fLib := Path.Combine(fSputnikRoot, 'lib');

  try
  //ScanJS(fTestRoot);
  //ScanJS(Path.Combine(Path.Combine(fTestRoot, 'Conformance'), '07_Lexical_Conventions'));
  except

  end;
end;

method SputnikTests.RunTest(aName: string); 
begin
  if fFramework = nil then
    fFramework := File.ReadAllText(Path.Combine(fLib, 'framework.js'));
  var lScriptFilename := Path.Combine(fTestRoot, aName);
  var lScript := fFramework + File.ReadAllText(lScriptFilename);
  lScript := fInclude.Replace(lScript, new System.Text.RegularExpressions.MatchEvaluator(@Include));
  lScript := fSpecialCall.Replace(lScript, new System.Text.RegularExpressions.MatchEvaluator(@Specialcall));
  using se := new RemObjects.Script.EcmaScriptComponent() do begin
    se.RunInThread := false;
    se.Debug := false;
    se.SourceFileName := aName;
    se.Source := lScript;
    if lScript.IndexOf('@negative') <> - 1 then begin
      try
        se.Run();
        
        Xunit.Assert.True(false, 'Should have throw an exception');
      except
        // expect an exception!
      end;
    end else
      se.Run;
  end;
end;

method SputnikTests.ScanJS(aScan: String);
begin
  var lItems :=new DirectoryInfo(aScan).GetFileSystemInfos();
  for each el in lItems do begin
    if el is DirectoryInfo then continue;
    if el.FullName.EndsWith('.js') then begin
      fTests.Add(new SputnikTest(Owner := self, Name := el.FullName.Substring(fTestRoot.Length+1)));
    end; 
  end;
  for each el in lItems do begin
    if el.Name = '.svn' then continue;
    if el is not DirectoryInfo then continue;
    ScanJS(el.FullName);
  end;
end;

method SputnikTests.Include(arg: System.Text.RegularExpressions.Match): string;
begin
  if arg.Groups[1].Value = 'environment.js' then begin
    exit '';
  end;

  exit File.ReadAllText(Path.Combine(fLib, arg.Groups[1].Value));
end;

method SputnikTests.SpecialCall(aMatch: System.Text.RegularExpressions.Match): string;
begin
  case aMatch.Groups[1].Value of
    'ERROR': exit 'testFailed';
    'FAIL': exit 'testFailed';
    'PRINT': exit 'testPrint';
  else
    Xunit.Assert.True(false, 'Invalid special command: '+aMatch.Groups[1].Value);
  end; // case
end;

method SputnikTest.GetCustomAttributes(attributeType: System.Type): sequence of Xunit.Sdk.IAttributeInfo;
begin
  exit [];
end;

method SputnikTest.Execute(testClass: System.Object): Xunit.Sdk.MethodResult;
begin
  try
   Run(self);
  except
    on e: exception do exit new Xunit.Sdk.FailedResult(self, e, DisplayName);
  end;
  exit new Xunit.Sdk.PassedResult(self, DisplayName);
end;

method SputnikTest.GetHashCode: Int32;
begin
  exit inherited;
end;

method SputnikTest.Equals(obj: Object): Boolean;
begin
  exit SputnikTest(obj):Name = Name;
end;

method SputnikTest.Run(Data: SputnikTest);
begin
  Owner.RunTest(Name);
end;


method SputnikException.ToString: String;
begin
  exit Message;
end;

end.
