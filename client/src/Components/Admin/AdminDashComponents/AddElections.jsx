import { React, Fragment } from 'react'
import ElectionList from './utilities/ElectionList'
import { useForm } from "react-hook-form"
import { useState, useEffect } from 'react'
import UserABI from '../../../../../smart_contract/build/contracts/Voters.json'
import { ContractAddress } from '../../../config.js'
import { ethers } from 'ethers'
import { Oval } from 'react-loader-spinner'

const Loader = () => {
  return (
    <div className='flex flex-col items-center justify-center'>
      <Oval
        height={25}
        width={25}
        color="green"
        wrapperStyle={{}}
        wrapperClass=""
        visible={true}
        ariaLabel='oval-loading'
        secondaryColor="lime"
        strokeWidth={2}
        strokeWidthSecondary={2}
      />
    </div>
  )
}

const Child = (props) => {
  console.log(props)
  return (
    <>
      {props.list.map((item, index) => (
        <Fragment key={index}>{item.name != "" && <ElectionList name={item.name} type={item.t} totVote={item.totalVote} isActive={item.isActive} key={item.id} />}</Fragment>
      ))}
    </>
  );
}

const AddElections = () => {
  const [data, setData] = useState([])
  const [electionName, setName] = useState("")
  const [electionType, setType] = useState("Plural Voting")
  const [chk, setChk] = useState(0)
  const [rcnfm, setConfirm] = useState(0)

  const { register, handleSubmit, formState: { errors, isValid } } = useForm({
    mode: "all"
  }
  )
  const selectionHandler = (e) => {
    console.log(e.target.value)
    setType(e.target.value)
  }
  useEffect(() => {
    setName("")
    let e = async () => { await getElectionList() }
    e().then(() => {
      console.log("Election data retrieved")
      setChk(1)
    }
    )
  }, [rcnfm])

  const onSubmit = async () => {
    await addElection()
    console.log("Submitted: " + electionName)
  }

  const getElectionList = async () => {
    try {
      if (window.ethereum) {
        const provider = new ethers.providers.Web3Provider(ethereum)
        const signer = provider.getSigner()
        const UserContract = new ethers.Contract(
          ContractAddress,
          UserABI.abi,
          signer
        )
        let elections = await UserContract.getElectionList()
        setData(elections)
      }
      else {
        console.log("Ethereum object does not exist!")
      }
    } catch (error) {
      console.log(error)
    }
  }

  const addElection = async () => {
    try {
      if (window.ethereum) {
        const provider = new ethers.providers.Web3Provider(ethereum)
        const signer = provider.getSigner()
        const UserContract = new ethers.Contract(
          ContractAddress,
          UserABI.abi,
          signer
        )
        console.log(UserContract)
        await UserContract.addElection(electionName, electionType).then((log) => {
          provider.waitForTransaction(log.hash, 1).then((receipt) => {
            if (receipt) {
              if (receipt.status == 1)
                setConfirm(previousRcnfm => previousRcnfm + 1)
              else if (receipt.status == 0)
                console.log("Transaction Failed!");
            }
          })
        })
      }
      else {
        console.log("Ethereum object does not exist!")
      }
    } catch (error) {
      console.log('here\n', error)
    }
  }
  return (
    <div>
      <section className="mt-6 gap-8">
        <h1 className="text-2xl font-bold mb-8">Add Election</h1>
        <form
          id="form"
          onSubmit={handleSubmit(onSubmit)}
          className="w-full mx-auto rounded-lg bg-cyan-900 p-8 px-8"
        >
          <div className="flex flex-col text-[#e4d7ff] py-2">
            <label className="font-bold text-xl text-white">
              &nbsp;Election Name &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
              &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;Election Type
            </label>

            <div className="p-4 grid grid-cols-3 gap-4">
              <div className="col-span-2">
                <input
                  className="rounded-lg w-half bg-gray-800 mt-2 p-2 focus:border-blue-500 focus:bg-gray-800 focus:outline-none"
                  type="text"
                  {...register("electionName", {
                    required: true,
                    pattern: /^(?!\s+$).*$/,
                  })}
                  value={electionName}
                  onChange={(e) => setName(e.target.value)}
                />

                <select
                  style={{ marginLeft: "80px" }}
                  id="dropi"
                  className="rounded-lg w-half bg-gray-800 mt-2 p-2 focus:border-blue-500 focus:bg-gray-800 focus:outline-none"
                  type="text"
                  value={electionType}
                  onChange={(e) => selectionHandler(e)}
                >
                  <option value="Pluraity Voting">Plurality Voting</option>
                  <option value="Approval Voting">Approval Voting</option>
                  <option value="Quadratic Voting">Quadratic Voting</option>
                </select>
              </div>
              <div>
                <button
                  id="wallet-id"
                  className="w-full mt-2 p-2 bg-teal-500 shadow-lg shadow-teal-500/50 hover:shadow-teal-500/40 text-white font-semibold rounded-lg"
                >
                  Add
                </button>
              </div>
            </div>
            <h1 className=" text-red-500 font-bold">
              {errors.electionName?.type === "required" &&
                "Election Name is required"}
              {errors.electionName?.type === "pattern" &&
                "Election Name cannot contains only white-spaces"}
            </h1>
          </div>
        </form>
      </section>
      <section className="mt-6 gap-8">
        <h1 className="text-2xl font-bold mb-4">Election History</h1>
        <div className="min-w-[320px] gap-3 flex flex-col">
          <div className="grid  items-center justify-items-center grid-cols-4 gap-3 mb-4">
            <div className=" flex items-center gap-2">
              <span className="py-1 px-1 rounded-full font-bold text-center">
                Election Name
              </span>
            </div>
            <div className=" flex items-center gap-2">
              <span className="py-1 px-1 rounded-full font-bold text-center">
                Election Type
              </span>
            </div>
            <div>
              <span className="py-1 px-1 rounded-full font-bold flex items-center text-center">
                Total Vote Count
              </span>
            </div>
            <div>
              <span className="ml-10 py-1 px-1 rounded-full font-bold flex items-center">
                Status
              </span>
            </div>
          </div>
        </div>
        <div className="min-w-[320px] bg-white py-6 rounded-3xl shadow-2xl h-[29vh] gap-6 flex flex-col overflow-y-auto scrollbar">
          {/* {data} */}
          {chk ? <Child list={data} /> : <Loader />}
        </div>
      </section>
    </div>
  );
}

export default AddElections