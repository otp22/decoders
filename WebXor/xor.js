var XorDecoder={
	callback_begin:function(aKeyBytes,aMsgBytes,iKey,iMsg,nRetBound){},//decoding callback to be used for correction and other behavior, returns nothing
	callback_align:function(aKeyBytes,aMsgBytes,iKey,iMsg,nRetBound){return [0,0];},//decoding callback to be used for correction and other behavior, most return a message/key index delta pair array
	decode:function(aKeyBytes,aMsgBytes,iKeyStart)//the key in a byte array, the message in a byte array, and the offset position in the Key to start decoding
	{
		var aRetBytes=[];
		var nKeyBound=aKeyBytes.length;//length of the byte arrays
		var nMsgBound=aMsgBytes.length;
		var nKeySelectionLen=nKeyBound-iKeyStart;//length of the selection domain of bytes for decoding [iStart,nBound) (ie: from the current iStart value to the maximum index inclusively)
		var nRetBound=Math.min(nKeySelectionLen,nMsgBound);//the maximum decoded output (the return array) is bounded by the length of the message or remaining key bytes, whichever is smaller.

		this.callback_begin(aKeyBytes,aMsgBytes,iKeyStart,null,nRetBound);

		var iKey=iKeyStart;
		for(var iMsg=0; iMsg<nRetBound; iMsg++,iKey++){
			aDeltas=this.callback_align(aKeyBytes,aMsgBytes,iKey,iMsg,nRetBound);
			iKey+=aDeltas[0];
			iMsg+=aDeltas[1];
			var nKeyByte=aKeyBytes[iKey];
			var nMsgByte=aMsgBytes[iMsg];
			var nRetByte=nKeyByte^nMsgByte;
			aRetBytes.push(nRetByte);
		}
		return aRetBytes;
	}
}
var XorAutoalign={//class that determines message position (offset) error autoalignments for ANSI Text outputs. See https://code.google.com/p/otpxor/wiki/Autoalign for an in-depth explanation.
	nToleranceKey:2,//how key bytes should we play catch-up with when we have "missing" messages chars?
	nToleranceMsg:2,//how many "extra"/erroneous message chars should we skip?
	bEnable:false,
	isReadable:function(a){//determines if the byte value is graphable ANSI (ie: 0x00-0x7F, no special or nongraphing chars)
		return ( (a>=0x20 && a<=0x7E) || a==0x0d || a==0x0a || a==0x09 );
	},
	countReadable:function(aKeyBytes,aMsgBytes,iKey,iMsg,nRetBound){//counts the number of graphable ANSI bytes resulting from a XOR decode with given alignment
		var readable=0;
		for(;iMsg<nRetBound; iMsg++,iKey++) if(this.isReadable(aKeyBytes[iKey]^aMsgBytes[iMsg])) readable++;
		return readable;
	},
	suggestAlignmentSingle:function(aKeyBytes,aMsgBytes,iKey,iMsg,nRetBound){//suggest a message position (offset) alignment change of one buffer that will provide the most graphable ANSI.
		var suggestedDelta=0;
		var suggestedMaxReadable=0;
		for(var niDelta=0; niDelta<=this.nToleranceForward; niDelta++){
			var currentReadable=this.countReadable(aKeyBytes,aMsgBytes,iKey+niDelta,iMsg,nRetBound);
			if(currentReadable>suggestedMaxReadable){
				suggestedDelta=niDelta;
				suggestedMaxReadable=currentReadable;
			}
		}
		return [suggestedDelta,suggestedMaxReadable];
	},
	suggestAlignments:function(aKeyBytes,aMsgBytes,iKey,iMsg,nRetBound){//suggest key and message alignments to provide maximum readable characters.
		if(this.isReadable(aKeyBytes[iKey]^aMsgBytes[iMsg])) return [0,0];//if the current byte is already graphable ANSI, do not autosuggest anything.
		else{
			var aSuggestKey=suggestAlignmentDelta(aKeyBytes,aMsgBytes,iKey,iMsg,nRetBound)
			var aSuggestMsg=suggestAlignmentDelta(aMsgBytes,aKeyBytes,iMsg,iKey,nRetBound)//there is no internal implementation difference between key and msg buffers, so we can swap the two to check alignment on the opposite.
			if(aSuggestMsg[1]>aSuggestKey[1]) return [0,aSuggestMsg[0]];//compare readable counts and select
			else                              return [aSuggestKey[0],0]
		}
	}
}



/*
function bar(a,b,c,d){console.log("callback: Key:"+a+" Msg:"+b+" Off:"+c+" Len:"+d);}

XorDecoder.callback_begin=bar;
XorDecoder.callback_perbyte=bar;
var ret=XorDecoder.decode(key,msg,0);
alert(ret);
*/

