const todoService = require('../services/todoService');

async function getTodos(req, res, next) {
  try {
    const userId = req.user.sub;
    const filter = req.query.filter; // today, yesterday, this_week, this_month, this_year
    
    const todos = await todoService.getTodos(userId, filter);
    return res.status(200).json({
      message: 'Todos fetched successfully',
      data: todos
    });
  } catch (error) {
    return next(error);
  }
}

async function createTodo(req, res, next) {
  try {
    const userId = req.user.sub;
    const { title, description, due_date } = req.body;
    
    if (!title) {
      return res.status(400).json({ message: 'Title is required' });
    }

    const todo = await todoService.createTodo(userId, title, description, due_date);
    return res.status(201).json({
      message: 'Todo created successfully',
      data: todo
    });
  } catch (error) {
    return next(error);
  }
}

async function updateTodo(req, res, next) {
  try {
    const userId = req.user.sub;
    const todoId = req.params.id;
    const { title, description, due_date, status } = req.body;

    const existingTodo = await todoService.getTodoById(todoId);
    if (!existingTodo) {
      return res.status(404).json({ message: 'Todo not found' });
    }
    
    if (existingTodo.user_id !== userId && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Forbidden' });
    }

    const updatedTodo = await todoService.updateTodo(
      todoId,
      title || existingTodo.title,
      description !== undefined ? description : existingTodo.description,
      due_date !== undefined ? due_date : existingTodo.due_date,
      status || existingTodo.status
    );

    return res.status(200).json({
      message: 'Todo updated successfully',
      data: updatedTodo
    });
  } catch (error) {
    return next(error);
  }
}

async function deleteTodo(req, res, next) {
  try {
    const userId = req.user.sub;
    const todoId = req.params.id;

    const existingTodo = await todoService.getTodoById(todoId);
    if (!existingTodo) {
      return res.status(404).json({ message: 'Todo not found' });
    }
    
    if (existingTodo.user_id !== userId && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Forbidden' });
    }

    await todoService.deleteTodo(todoId);
    return res.status(200).json({
      message: 'Todo deleted successfully'
    });
  } catch (error) {
    return next(error);
  }
}

module.exports = {
  getTodos,
  createTodo,
  updateTodo,
  deleteTodo
};
