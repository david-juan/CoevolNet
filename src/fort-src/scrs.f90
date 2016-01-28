! Copyright (c) 2015 Simone Marsili
! 
! Permission is hereby granted, free of charge, to any person obtaining a copy
! of this software and associated documentation files (the "Software"), to deal
! in the Software without restriction, including without limitation the rights
! to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
! copies of the Software, and to permit persons to whom the Software is
! furnished to do so, subject to the following conditions:
! 
! The above copyright notice and this permission notice shall be included in all
! copies or substantial portions of the Software.
! 
! THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
! IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
! FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
! AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
! LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
! OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
! SOFTWARE.

module scrs
  use nrtype
  implicit none
  private 

  public :: compute_scores
  public :: print_scores

  real(SP), allocatable, save :: scores(:,:)

contains

  subroutine compute_scores()
    use data, only: nv,ns,neff
    use model, only: fields,couplings
    integer :: iv,jv,k,is,js
    real(SP) :: sums(nv),totsum
    integer(I4B) :: err
    real(SP) :: rpseudo=0.5_SP,qq,ll,sij
    real(SP) :: p11,p22,p12,p21,nrm,fpi(ns-1),fpj(ns-1),fpij(ns-1,ns-1),enti,entj,entij,mij

    ! at the very end of the run
    allocate(scores(nv,nv),stat=err)
    scores = 0.0_SP

    ! compute scores
    k = 0
    do jv = 1,nv-1
       do iv = jv+1,nv
          k = k + 1
          scores(iv,jv) = frobenius(couplings(:ns-1,:ns-1,k))
          scores(jv,iv) = scores(iv,jv)
       end do
    end do
    
    call apc_correction(scores)

  contains

    real(SP) function frobenius(a)
      real(SP), intent(in) :: a(:,:)

      frobenius = sqrt(sum(a**2))

    end function frobenius

    subroutine apc_correction(a)
      real(SP), intent(inout) :: a(:,:)
      real(SP), allocatable :: sums(:)
      real(SP) :: totsum
      integer(I4B) :: err
      integer(I4B) :: i,j
      integer(I4B) :: n

      n = size(a,1)
      allocate(sums(n),stat=err)

      do i = 1,n
         sums(i) = sum(a(:,i))
      end do
      totsum = sum(sums)
      
      do j = 1,n
         do i = j,n
            a(i,j) = a(i,j) - sums(i)*sums(j)/totsum
            a(j,i) = a(i,j)
         end do
      end do

      deallocate(sums)
      
    end subroutine apc_correction

  end subroutine compute_scores

  subroutine print_scores(uscrs)
    use units
    use data, only: nv,ns
    use model, only: fields,couplings
    integer(I4B), intent(in) :: uscrs
    integer(I4B) :: usc,uprm
    integer(I4B) :: err
    integer(I4B) :: iv,jv,is,js,k
    character(80) :: filename
    real(8) :: sij

    do iv = 1,nv-1
       do jv = iv+1,nv
          sij = scores(iv,jv)
          write(uscrs,'(i5,1x,i5,1x,f8.5)') iv,jv,sij
       end do
    end do

  end subroutine print_scores

end module scrs
