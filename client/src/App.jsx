import { useState,useEffect } from 'react'
import './App.css'
import  Layout  from "./Components/Layout"
import  Home  from "./Components/Home"
import Register from './Components/Register'
import { Routes,Route } from 'react-router-dom'
import Login from './Components/Login'
import detectEthereumProvider from '@metamask/detect-provider'
import AuthConsumer from './auth/useAuth'
import { ethers } from "ethers"

function App() {

  // const googleTranslateElementInit = () => {
  //   new window.google.translate.TranslateElement(
  //     {
  //       pageLanguage: "en",
  //       autoDisplay: false
  //     },
  //     "google_translate_element"
  //   );
  // };

  // useEffect(() => {
  //   var addScript = document.createElement("script");
  //   addScript.setAttribute(
  //     "src",
  //     "//translate.google.com/translate_a/element.js?cb=googleTranslateElementInit"
  //   );
   

  //   document.body.appendChild(addScript);
  //   window.googleTranslateElementInit = googleTranslateElementInit;
  
  //   // var select = document.getElementsByClassName('goog-te-combo')[0];

  //   // var opt = document.createElement('option');
  //   // opt.value = "en";
  //   // opt.innerHTML = "English";
  //   // select.appendChild(opt);
  // }, []);
  const [flg, setFlg] = useState(true)
  const [loading, setLoading] = useState(true)
  const [user, setUser] = useState(null)
  const { role, setRole } = AuthConsumer()

  useEffect(() => {
    checkProvider()
  }, [])

  useEffect(() => {
    getRole()
  }, [user])

  const getRole = async () => {
    try {
      if (window.ethereum) {
        const provider = new ethers.providers.Web3Provider(ethereum)
        console.log(provider)
        
        const signer = provider.getSigner()
        const UserContract = new ethers.Contract(
          ContractAddress,
          UserABI.abi,
          signer
        )
        await UserContract.getUserDetails().then(async (dat) => {
          setUser(dat)
          user != null && await UserContract.getUserRole(user.id).then((res) => {
            setRole(res)
          })
        })
      }
      else {
        console.log("Ethereum object does not exist!")
      }
    } catch (error) {
      console.log(error)
    }
  }



  const checkProvider = async () => {
    const provider = await detectEthereumProvider()
    if (provider) {
      console.log('Ethereum successfully detected!')
      setFlg(true)
    } else {
      setFlg(false)
      console.error('Please install MetaMask!')
    }
    setLoading(false)
  }

  return (
    <>
      <div id="google_translate_element" className='absolute bottom-0 right-0'></div>
        <Routes>
            <Route path='/' element={<Layout/>}>
              <Route index element={<Home/>}/>
              <Route exact path='/Register' element={<Register/>}/>
              <Route exact path='/login' element={<Login/>}/>
            </Route>
        </Routes>
      
    </>
  )
}

export default App
