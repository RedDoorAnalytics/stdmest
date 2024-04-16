capture erase lstdmest.mlib
quietly {
    do "./mata/stdmest.mata"
    do "./mata/stdmestm.mata"

    mata: mata mlib create lstdmest, dir(.)
    mata: mata mlib add lstdmest *(), dir(.)
    mata: mata d *()
	mata mata clear
	mata mata mlib index
}
