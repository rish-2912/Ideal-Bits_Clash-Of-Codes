import { useState } from 'react'
import './App.css'
import  Layout  from "./Components/Layout"
import  Home  from "./Components/Home"
import { Routes,Route } from 'react-router-dom'

function App() {

  return (
    <>
      <Routes>
          <Route path='/' element={<Layout/>}>
            <Route index element={<Home/>}/>
          </Route>
      </Routes>
    </>
  )
}

export default App
