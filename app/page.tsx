'use client'

import { useState, useEffect, useMemo } from 'react'
import { Plus, Trash2, Check, X, Filter, Search } from 'lucide-react'

interface Todo {
  id: string
  text: string
  completed: boolean
  createdAt: Date
}

type FilterType = 'all' | 'active' | 'completed'

// ハイライト表示用コンポーネント
const HighlightedText = ({ text, searchText }: { text: string, searchText: string }) => {
  if (!searchText.trim()) {
    return <span>{text}</span>
  }

  const parts = text.split(new RegExp(`(${searchText.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')})`, 'gi'))
  
  return (
    <span>
      {parts.map((part, index) => (
        part.toLowerCase() === searchText.toLowerCase() ? (
          <span key={index} className="bg-yellow-200 text-yellow-900 rounded px-1">
            {part}
          </span>
        ) : (
          <span key={index}>{part}</span>
        )
      ))}
    </span>
  )
}

export default function TodoApp() {
  const [todos, setTodos] = useState<Todo[]>([])
  const [inputText, setInputText] = useState('')
  const [filter, setFilter] = useState<FilterType>('all')
  const [searchText, setSearchText] = useState('')

  // ローカルストレージからTodoを読み込み
  useEffect(() => {
    const savedTodos = localStorage.getItem('todos')
    if (savedTodos) {
      try {
        const parsedTodos = JSON.parse(savedTodos).map((todo: any) => ({
          ...todo,
          createdAt: new Date(todo.createdAt)
        }))
        setTodos(parsedTodos)
      } catch (error) {
        console.error('Todoの読み込みに失敗しました:', error)
      }
    }
  }, [])

  // Todoの変更をローカルストレージに保存
  useEffect(() => {
    localStorage.setItem('todos', JSON.stringify(todos))
  }, [todos])

  const addTodo = () => {
    if (inputText.trim() === '') return

    const newTodo: Todo = {
      id: Date.now().toString(),
      text: inputText.trim(),
      completed: false,
      createdAt: new Date()
    }

    setTodos([newTodo, ...todos])
    setInputText('')
  }

  const toggleTodo = (id: string) => {
    setTodos(todos.map(todo =>
      todo.id === id ? { ...todo, completed: !todo.completed } : todo
    ))
  }

  const deleteTodo = (id: string) => {
    setTodos(todos.filter(todo => todo.id !== id))
  }

  // フィルタリングと検索機能
  const filteredTodos = useMemo(() => {
    let result = todos

    // フィルタを適用
    switch (filter) {
      case 'active':
        result = result.filter(todo => !todo.completed)
        break
      case 'completed':
        result = result.filter(todo => todo.completed)
        break
      default:
        // 'all' の場合はそのまま
        break
    }

    // 検索を適用
    if (searchText.trim()) {
      result = result.filter(todo =>
        todo.text.toLowerCase().includes(searchText.toLowerCase())
      )
    }

    return result
  }, [todos, filter, searchText])

  const completedCount = todos.filter(todo => todo.completed).length
  const activeCount = todos.filter(todo => !todo.completed).length
  const totalCount = todos.length

  // フィルタボタンのスタイル
  const getFilterButtonStyle = (filterType: FilterType) => {
    const isActive = filter === filterType
    return `px-4 py-2 rounded-lg font-medium transition-all duration-200 ${
      isActive
        ? 'bg-blue-500 text-white shadow-md'
        : 'bg-white text-gray-600 hover:bg-blue-50 hover:text-blue-600'
    }`
  }

  // フィルタラベル
  const getFilterLabel = (filterType: FilterType) => {
    switch (filterType) {
      case 'all':
        return `全て (${totalCount})`
      case 'active':
        return `未完了 (${activeCount})`
      case 'completed':
        return `完了済み (${completedCount})`
    }
  }

  // 検索クリア
  const clearSearch = () => {
    setSearchText('')
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 py-8 px-4">
      <div className="max-w-2xl mx-auto">
        {/* ヘッダー */}
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-gray-800 mb-2">
            Todo管理アプリ
          </h1>
          <p className="text-gray-600">
            完了: {completedCount} / 全体: {totalCount}
          </p>
        </div>

        {/* Todo追加フォーム */}
        <div className="bg-white rounded-xl shadow-lg p-6 mb-6">
          <div className="flex gap-3">
            <input
              type="text"
              value={inputText}
              onChange={(e) => setInputText(e.target.value)}
              onKeyPress={(e) => e.key === 'Enter' && addTodo()}
              placeholder="新しいタスクを入力..."
              className="flex-1 px-4 py-3 border-2 border-gray-200 rounded-lg focus:border-blue-500 focus:outline-none transition-colors text-gray-900 placeholder:text-gray-500"
            />
            <button
              onClick={addTodo}
              className="bg-blue-500 hover:bg-blue-600 text-white px-6 py-3 rounded-lg font-medium transition-colors flex items-center gap-2"
            >
              <Plus size={20} />
              追加
            </button>
          </div>
        </div>

        {/* 検索フィールド */}
        {todos.length > 0 && (
          <div className="bg-white rounded-xl shadow-lg p-6 mb-6">
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                <Search size={20} className="text-gray-400" />
              </div>
              <input
                type="text"
                value={searchText}
                onChange={(e) => setSearchText(e.target.value)}
                placeholder="タスクを検索..."
                className="w-full pl-12 pr-12 py-3 border-2 border-gray-200 rounded-lg focus:border-blue-500 focus:outline-none transition-colors text-gray-900 placeholder:text-gray-500"
              />
              {searchText && (
                <button
                  onClick={clearSearch}
                  className="absolute inset-y-0 right-0 pr-4 flex items-center"
                >
                  <X size={20} className="text-gray-400 hover:text-gray-600 transition-colors" />
                </button>
              )}
            </div>
            {searchText && (
              <p className="text-sm text-gray-500 mt-2">
                検索結果: {filteredTodos.length}件
              </p>
            )}
          </div>
        )}

        {/* フィルタボタン */}
        {todos.length > 0 && (
          <div className="bg-white rounded-xl shadow-lg p-4 mb-6">
            <div className="flex items-center gap-3">
              <Filter size={20} className="text-gray-500" />
              <span className="text-gray-700 font-medium">フィルタ:</span>
              <div className="flex gap-2 flex-wrap">
                {(['all', 'active', 'completed'] as FilterType[]).map((filterType) => (
                  <button
                    key={filterType}
                    onClick={() => setFilter(filterType)}
                    className={getFilterButtonStyle(filterType)}
                  >
                    {getFilterLabel(filterType)}
                  </button>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* Todo一覧 */}
        <div className="space-y-3">
          {filteredTodos.length === 0 ? (
            <div className="bg-white rounded-xl shadow-lg p-8 text-center">
              {todos.length === 0 ? (
                <>
                  <p className="text-gray-500 text-lg">タスクがありません</p>
                  <p className="text-gray-400 text-sm mt-2">上のフォームから新しいタスクを追加してください</p>
                </>
              ) : searchText ? (
                <>
                  <p className="text-gray-500 text-lg">「{searchText}」に一致するタスクがありません</p>
                  <p className="text-gray-400 text-sm mt-2">別のキーワードで検索するか、検索をクリアしてください</p>
                </>
              ) : (
                <>
                  <p className="text-gray-500 text-lg">
                    {filter === 'active' && '未完了のタスクがありません'}
                    {filter === 'completed' && '完了済みのタスクがありません'}
                  </p>
                  <p className="text-gray-400 text-sm mt-2">
                    {filter === 'active' && '新しいタスクを追加するか、他のフィルタを選択してください'}
                    {filter === 'completed' && 'タスクを完了するか、他のフィルタを選択してください'}
                  </p>
                </>
              )}
            </div>
          ) : (
            filteredTodos.map((todo) => (
              <div
                key={todo.id}
                className={`bg-white rounded-xl shadow-lg p-4 transition-all duration-200 hover:shadow-xl ${
                  todo.completed ? 'opacity-75' : ''
                }`}
              >
                <div className="flex items-center gap-4">
                  <button
                    onClick={() => toggleTodo(todo.id)}
                    className={`flex-shrink-0 w-6 h-6 rounded-full border-2 flex items-center justify-center transition-colors ${
                      todo.completed
                        ? 'bg-green-500 border-green-500 text-white'
                        : 'border-gray-300 hover:border-green-400'
                    }`}
                  >
                    {todo.completed && <Check size={16} />}
                  </button>
                  
                  <div className="flex-1">
                    <p className={`text-lg ${
                      todo.completed 
                        ? 'line-through text-gray-500' 
                        : 'text-gray-800'
                    }`}>
                      <HighlightedText text={todo.text} searchText={searchText} />
                    </p>
                    <p className="text-sm text-gray-400 mt-1">
                      {todo.createdAt.toLocaleString('ja-JP')}
                    </p>
                  </div>
                  
                  <button
                    onClick={() => deleteTodo(todo.id)}
                    className="flex-shrink-0 p-2 text-red-500 hover:bg-red-50 rounded-lg transition-colors"
                  >
                    <Trash2 size={18} />
                  </button>
                </div>
              </div>
            ))
          )}
        </div>

        {/* フッター */}
        {todos.length > 0 && (
          <div className="mt-8 text-center">
            <p className="text-gray-500 text-sm">
              💪 今日も頑張りましょう！
            </p>
          </div>
        )}
      </div>
    </div>
  )
} 