import {create} from 'ipfs-http-client'
import {Buffer} from 'buffer'

const auth = 'Basic ' + Buffer.from("2MZ75Kli9GbOCprmpteEs0ZejO9" + ':' + "7dd9ace6a556c33573363ce0892c5b56").toString('base64')
const ipfsClient=async()=>{
    
    const ipfs = await create(
        {
            host: "ipfs.infura.io",
            port: 5001,
            protocol: 'https',
            apiPath:'/api/v0',
            headers: {
                authorization: auth
            }
        }
    );
    return ipfs;
}

export async function saveText(data) {
    try{
        let ipfs = await ipfsClient()
        let result = await ipfs.add(data)
        return result.path
    }
    catch(err){
        return err
    }
}

export async function getText(cid) {
    try{
        let ipfs = await ipfsClient()
        const stream=ipfs.cat(cid)
        const decoder=new TextDecoder()
        let data=''
        for await (const chunk of stream) {
            data += decoder.decode(chunk, { stream: true })
        }
        return data
    }
    catch(err){
        return err
    }
}