import 'dart:io';

import 'package:get/get.dart';

class PermissionService extends GetxController {
  RandomAccessFile? lockFileHandle;
  
  /// 检查当前程序是否以管理员权限运行
  Future<bool> isUserAdmin() async {
    if (!Platform.isWindows) {
      return false;
    }
    
    try {
      // 使用 PowerShell 命令检查管理员权限
      final result = await Process.run('powershell', [
        '-Command',
        '([Security.Principal.WindowsIdentity]::GetCurrent()).Groups -contains "S-1-5-32-544"'
      ], runInShell: true);
      
      return result.exitCode == 0 && result.stdout.toString().trim().toLowerCase() == 'true';
    } catch (e) {
      return false;
    }
  }

  /// 锁住文件，防止其他进程启动
  Future<bool> lockFile() async {
    try {
      // 确保目录存在
      final directory = Directory('~/.nursor');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      
      final file = File('~/.nursor/running.lock');
      lockFileHandle = await file.open(mode: FileMode.write);
      
      // 尝试获取独占锁
      await lockFileHandle!.lock();
      
      // 写入当前进程信息
      await lockFileHandle!.writeString('PID: Time: ${DateTime.now()}');
      await lockFileHandle!.flush();
      
      return true;
    } catch (e) {
      print('锁住文件失败: $e');
      await unlockFile();
      return false;
    }
  }

  /// 释放文件锁
  Future<void> unlockFile() async {
    try {
      if (lockFileHandle != null) {
        await lockFileHandle!.unlock();
        await lockFileHandle!.close();
        lockFileHandle = null;
      }
    } catch (e) {
      print('释放文件锁时出错: $e');
    }
  }

  /// 检查文件锁状态
  Future<bool> isFileLocked() async {
    try {
      final userHome = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
      final file = File('$userHome/.nursor/running.lock');
      if (!await file.exists()) {
        return false;
      }
      
      // 尝试以独占模式打开文件
      final testFile = await file.open(mode: FileMode.write);
      await testFile.lock();
      // await testFile.unlock();
      // await testFile.close();
      return false; // 如果能获取锁，说明没有其他进程锁住
    } catch (e) {
      return true; // 如果获取锁失败，说明文件被其他进程锁住
    }
  }

  @override
  void onClose() {
    unlockFile();
    super.onClose();
  }

  /// 检查当前用户是否属于管理员组
  Future<bool> isUserInAdminGroup() async {
    if (!Platform.isWindows) {
      return false;
    }
    
    try {
      // 使用 PowerShell 命令检查用户组
      final result = await Process.run('powershell', [
        '-Command',
        '([Security.Principal.WindowsIdentity]::GetCurrent()).Groups -contains "S-1-5-32-544"'
      ], runInShell: true);
      
      return result.exitCode == 0 && result.stdout.toString().trim().toLowerCase() == 'true';
    } catch (e) {
      print('检查用户组权限时出错: $e');
      return false;
    }
  }

  /// 检查是否需要管理员权限（综合检查）
  Future<bool> needsAdminPrivileges() async {
    if (!Platform.isWindows) {
      return false;
    }
    
    final isAdmin = await isUserAdmin();
    final isInAdminGroup = await isUserInAdminGroup();
    
    // 如果当前不是管理员权限运行，但用户属于管理员组，则需要管理员权限
    return !isAdmin && isInAdminGroup;
  }

  /// 简单的管理员权限检查方法
  Future<bool> isRunningAsAdmin() async {
    return await isUserAdmin();
  }

  /// 使用注册表检查管理员权限的备用方法
  Future<bool> isUserAdminAlternative() async {
    if (!Platform.isWindows) {
      return false;
    }
    
    try {
      // 尝试访问需要管理员权限的注册表项
      final result = await Process.run('powershell', [
        '-Command',
        'try { Get-ItemProperty -Path "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System" -ErrorAction Stop | Out-Null; Write-Output "True" } catch { Write-Output "False" }'
      ], runInShell: true);
      
      return result.exitCode == 0 && result.stdout.toString().trim() == 'True';
    } catch (e) {
      print('检查管理员权限时出错: $e');
      return false;
    }
  }
}