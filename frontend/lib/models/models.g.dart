// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 3;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as int,
      email: fields[1] as String,
      username: fields[2] as String,
      fullName: fields[3] as String?,
      isActive: fields[4] as bool,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.fullName)
      ..writeByte(4)
      ..write(obj.isActive)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 4;

  @override
  Project read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Project(
      id: fields[0] as int,
      name: fields[1] as String,
      description: fields[2] as String?,
      color: fields[3] as String,
      ownerId: fields[4] as int,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.color)
      ..writeByte(4)
      ..write(obj.ownerId)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 5;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as int,
      title: fields[1] as String,
      notes: fields[2] as String?,
      description: fields[3] as String?,
      column: fields[4] as String,
      estimatedTime: fields[5] as int,
      actualTime: fields[6] as int,
      taskType: fields[7] as String?,
      taskPriority: fields[8] as String?,
      priority: fields[9] as TaskPriority,
      status: fields[10] as TaskStatus,
      tags: (fields[11] as List?)?.cast<String>(),
      estimatedPomodoros: fields[12] as int?,
      dueDate: fields[13] as DateTime?,
      reminderEnabled: fields[14] as bool,
      reminderOffset: fields[15] as int,
      isUrgent: fields[16] as bool,
      isImportant: fields[17] as bool,
      projectId: fields[18] as int,
      ownerId: fields[19] as int,
      createdAt: fields[20] as DateTime,
      updatedAt: fields[21] as DateTime,
      completedAt: fields[22] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.notes)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.column)
      ..writeByte(5)
      ..write(obj.estimatedTime)
      ..writeByte(6)
      ..write(obj.actualTime)
      ..writeByte(7)
      ..write(obj.taskType)
      ..writeByte(8)
      ..write(obj.taskPriority)
      ..writeByte(9)
      ..write(obj.priority)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.tags)
      ..writeByte(12)
      ..write(obj.estimatedPomodoros)
      ..writeByte(13)
      ..write(obj.dueDate)
      ..writeByte(14)
      ..write(obj.reminderEnabled)
      ..writeByte(15)
      ..write(obj.reminderOffset)
      ..writeByte(16)
      ..write(obj.isUrgent)
      ..writeByte(17)
      ..write(obj.isImportant)
      ..writeByte(18)
      ..write(obj.projectId)
      ..writeByte(19)
      ..write(obj.ownerId)
      ..writeByte(20)
      ..write(obj.createdAt)
      ..writeByte(21)
      ..write(obj.updatedAt)
      ..writeByte(22)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskPriorityAdapter extends TypeAdapter<TaskPriority> {
  @override
  final int typeId = 0;

  @override
  TaskPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskPriority.low;
      case 1:
        return TaskPriority.medium;
      case 2:
        return TaskPriority.high;
      case 3:
        return TaskPriority.urgent;
      default:
        return TaskPriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, TaskPriority obj) {
    switch (obj) {
      case TaskPriority.low:
        writer.writeByte(0);
        break;
      case TaskPriority.medium:
        writer.writeByte(1);
        break;
      case TaskPriority.high:
        writer.writeByte(2);
        break;
      case TaskPriority.urgent:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskStatusAdapter extends TypeAdapter<TaskStatus> {
  @override
  final int typeId = 1;

  @override
  TaskStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskStatus.todo;
      case 1:
        return TaskStatus.inProgress;
      case 2:
        return TaskStatus.done;
      case 3:
        return TaskStatus.completed;
      case 4:
        return TaskStatus.cancelled;
      default:
        return TaskStatus.todo;
    }
  }

  @override
  void write(BinaryWriter writer, TaskStatus obj) {
    switch (obj) {
      case TaskStatus.todo:
        writer.writeByte(0);
        break;
      case TaskStatus.inProgress:
        writer.writeByte(1);
        break;
      case TaskStatus.done:
        writer.writeByte(2);
        break;
      case TaskStatus.completed:
        writer.writeByte(3);
        break;
      case TaskStatus.cancelled:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProjectPriorityAdapter extends TypeAdapter<ProjectPriority> {
  @override
  final int typeId = 2;

  @override
  ProjectPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProjectPriority.low;
      case 1:
        return ProjectPriority.medium;
      case 2:
        return ProjectPriority.high;
      default:
        return ProjectPriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, ProjectPriority obj) {
    switch (obj) {
      case ProjectPriority.low:
        writer.writeByte(0);
        break;
      case ProjectPriority.medium:
        writer.writeByte(1);
        break;
      case ProjectPriority.high:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
