import lldb
import shlex

def stack(debugger, command, result, internal_dict):
  tpl = 'memory read {0} -c `$rbp-$rsp` $rbp'
  
  command = ' '.join(shlex.split(command))
  command = tpl.format(command)
  
  lldb.debugger.HandleCommand(command)

def __lldb_init_module(debugger, internal_dict):
  debugger.HandleCommand('command script add -f stack.stack stack')
