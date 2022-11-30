library dll;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  System.SysUtils,
  System.Classes;

{$R *.res}


//TYPES
type
  queuePointer = ^elementOfQueue;
  elementOfQueue = record
    data: string;
    nextData: queuePointer;
  end;
//VARIABLES
var
  aQueue,zQueue,viewQueue:queuePointer;
  textHolder:string;
  isSaved:boolean=true;
  isFirst:boolean=true;
//OBJECTS

//private
procedure addToQueue(dataInput: string; var endOfQueue: queuePointer;var beginningOfQueue: queuePointer; var viewOfQueue: queuePointer);
var point:queuePointer;
begin
  point:=endOfQueue;
  New(endOfQueue);
  with endOfQueue^ do
  begin
    data:=dataInput;
    nextData:=nil;
  end;
  if point<>nil then
    begin
      point^.nextData:=endOfQueue;
    end
  else
    isFirst:=false;
  if isSaved then
    isSaved:=false;
  if aQueue=nil then
        begin
          aQueue:=zQueue;
          viewQueue:=aQueue;
        end;
end;
procedure removeFromQueue(var firstQueuePointVariable:queuePointer);
var point:queuePointer;
begin
if firstQueuePointVariable<>nil then
  begin
    with firstQueuePointVariable^ do
      begin
        point:=nextData;
      end;
    Dispose(firstQueuePointVariable);
    if ViewQueue=firstQueuePointVariable then
      ViewQueue:=point;
    firstQueuePointVariable:=point;
    if isSaved then
      isSaved:=false
  end
else
  isFirst:=true;
end;
//public
procedure Add(data:string);stdcall;
begin
  //add data public
  addToQueue(data,zQueue,aQueue,viewQueue);
end;
function Remove():boolean;stdcall;
begin
  //remove data public
  Result:=true;
  if aQueue=nil then
    begin
      zQueue:=nil;
      Result:=false
    end
  else
    removeFromQueue(aQueue);
end;
function GetCurrentElement():string;stdcall;
begin
  //get current view public
  Result:='';
  if isFirst then
    viewQueue:=aQueue;
  if viewQueue<>nil then
    with viewQueue^ do
      Result:=data
end;
function SetNextElement():boolean;stdcall;
var point:queuePointer;
begin
  //switch to next element public
  Result:=false;
  if viewQueue<>nil then
    begin
      with viewQueue^ do
        begin
          point:=nextData;
        end;
      viewQueue:=point;
      Result:=true;
    end;
end;
function SetFirstElement():boolean;stdcall;
begin
  Result:=false;
  viewQueue:=aQueue;
  if viewQueue<>nil then
    Result:=true;
end;
function GetSavedState():boolean;stdcall;
begin
  Result:=isSaved;
end;
procedure SetSaveState(state:boolean);stdcall;
begin
  isSaved:=state;
end;
function GetHasElements():boolean;stdcall
begin
  Result:=false;
  if aQueue<>nil then
    Result:=true
end;
exports
  Add,
  Remove,
  GetCurrentElement,
  SetNextElement,
  SetFirstElement,
  GetSavedState,
  SetSaveState,
  GetHasElements;
begin
end.
