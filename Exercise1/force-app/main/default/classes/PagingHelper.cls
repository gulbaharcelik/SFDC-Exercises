public virtual class PagingHelper {
    public integer offset = 0;  //keeps track of the offset
	public Integer listSize = 20; //default value
    public integer totalSize;

    public PageReference Beginning(){
		offset = 0;
		return null;
	}

	public PageReference Previous(){
		offset -= listSize;
		return null;
	}

	public PageReference Next(){
		offset += listSize;
		return null;
	}

	public PageReference End(){
		offset = totalSize - math.mod(totalSize, listSize);
		return null;
	}

	public Boolean getDisablePrevious(){
		if (offset > 0)
			return false;
		else
			return true;
	}

	public Boolean getDisableNext(){
		if (offset + listSize < totalSize)
			return false;
		else
			return true;
	}

	public Integer getTotalSize(){
		return totalSize;
	}

	public Integer getPageNumber(){
		return offset / listSize + 1;
	}

	public Integer getTotalPages(){
		if (math.mod(totalSize, listSize) > 0){
			return totalSize / listSize + 1;
		} else{
			return (totalSize / listSize);
		}
	}
}