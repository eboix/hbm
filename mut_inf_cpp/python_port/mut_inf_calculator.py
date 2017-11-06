#include <iostream>
#include <algorithm>
#include <utility>
#include <vector>
#include <cmath>
#include <cassert>
#include <gmpxx.h>

using namespace std;

typedef vector<int> vi;
typedef vector<double> vd;
typedef pair<int, int> pii;
typedef pair<double, int> pdi;
// typedef pair<double, double> pdd;
typedef pair<mpf_class, mpf_class> pmpf;
typedef vector<mpf_class> vmpf;
typedef vector<pii> vpii;
typedef vector<vi> vvi;

# Want to calculate I(X; Y | L_n) =
# H(Y|L_n=0) - sum_{x = 0,1} p_x H(Y|X = x,L_n=0).

FLOAT_PREC = 100;

MAX_M = 20;

class MutInfCalculator:
##	public:
##		MutInfCalculator(vd, int, vpii);
##		mpf_class p[2][1<<MAX_M];
##		int e1[MAX_M];
##		int e2[MAX_M];
##		int num_edges;
##		double Q[2][2][2];
##		mpf_class calculated_mut_inf;
##		mpf_class get_mut_inf();
##		
##	private:
##		int get_bit(int, int);
##		void clear_states();
##		void add_vstate(int);
##		mpf_class eval_state(int, int);
##		pmpf calc_entropy(vmpf);
##		vmpf get_all_v0_estates(int);
##		vmpf get_all_estates();
};

def __init__(err, n, edge_list) {

	 if(n == 1) {
            calculated_mut_inf = 1;
            return;
	 }
	 
	for(int i = 0; i < 2; i++) {
		for(int j = 0; j < 2; j++) {                                         
			for(int k = 0; k < 2; k++) {
				int eq = 1;
				if(i != j) eq = 0;                                       
				if(k == eq) {                                             
					Q[i][j][k] = 1 - err[eq];
				}
				else {
					Q[i][j][k] = err[eq];
				}
				// cout << i << j << k << " " << Q[i][j][k] << endl;
			}
		}                                                           
	}
	
	num_edges = edge_list.size();
	assert(num_edges <= MAX_M);
	
	for(int i = 0; i < num_edges; i++) {
		e1[i] = edge_list[i].first;
		e2[i] = edge_list[i].second;
	}
	
	// Calculate the probability distribution.
	clear_states();
	// v_n = 0, wlog.
	for(int i = 0; i < (1<<(n-1)); i++) {
		add_vstate(i);
	}
	
	// Create the 
	pmpf tot_ent = calc_entropy(get_all_estates());
	pmpf ent0 = calc_entropy(get_all_v0_estates(0));
	pmpf ent1 = calc_entropy(get_all_v0_estates(1));
	
	mpf_class hy = tot_ent.second;
	mpf_class hyIx0 = (ent0.second * ent0.first + ent1.second * ent1.first) / tot_ent.first;
	
/*	cout << tot_ent.first << " " << tot_ent.second << endl;
	cout << ent0.first << " " << ent0.second << endl;
	cout << ent1.first << " " << ent1.second << endl;
	
	cout << hy << endl;
	cout << hyIx0 << endl;
	cout << (hy - hyIx0) << endl; */
	calculated_mut_inf = hy - hyIx0;
 }
	int MutInfCalculator::get_bit(int val, int i) {
		// Return ith bit of val.
		return (val >> i) % 2; 
	}

	void MutInfCalculator::clear_states() {
		for(int i = 0; i < (1<<num_edges); i++) {
			p[0][i] = mpf_class(0,FLOAT_PREC);
			p[1][i] = mpf_class(0,FLOAT_PREC);
		}
	}

	mpf_class MutInfCalculator::eval_state(int vstate, int estate) {
		mpf_class w(1,FLOAT_PREC);
		for(int i = 0; i < num_edges; i++) {
			int u = e1[i]; int v = e2[i];
			int us = get_bit(vstate, u);
			int vs = get_bit(vstate, v);
			int es = estate % 2;
			w *= Q[us][vs][es];
			estate = estate >> 1;
		}
		return w;
	}

	void MutInfCalculator::add_vstate(int i) {
		int v0 = get_bit(i,0);
		for(int j = 0; j < (1<<num_edges); j++) {
			p[v0][j] += eval_state(i,j);
		}
		return;
	}


	pmpf MutInfCalculator::calc_entropy(vmpf a) {
		mpf_class norm = 0;
		mpf_class h = 0;
		for(int i = 0; i < a.size(); i++) {
			mpf_class tp = a[i];
			// cout << tp << endl;
			if(tp == 0) continue;
			norm += tp;
			h +=  tp * log2(tp);
		}
		h = h / norm;
		h = h - log2(norm);
		return pmpf(norm,-h);
	}

	vmpf MutInfCalculator::get_all_v0_estates(int v0) {
		vmpf a;
		for(int i = 0; i < (1 << num_edges); i++) {
			a.push_back(p[v0][i]);	
		}
		return a;
	}

	vmpf MutInfCalculator::get_all_estates() {
		vmpf a = get_all_v0_estates(0);
		vmpf a2 = get_all_v0_estates(1);
		for(int i = 0; i < a.size(); i++) {
			a[i] += a2[i];
		}
		return a;
	}

	mpf_class MutInfCalculator::get_mut_inf() {
		return calculated_mut_inf;
	}


int main() {

	vd e(2,0);
	double a = 2.2;
	double b = -sqrt(4*a + 1) + a + 1;
	double N = 100;
	e[0] = 1-a/N;
	e[1] = b/N;
//	for(e[0] = 0; e[0] <= 1; e[0] += 0.1) {
//		for(e[1] = 0; e[1] <= 1; e[1] += 0.1) {
		mpf_class tot_mut_inf(0,FLOAT_PREC);
		vpii tmp_edge;
		int n = 10;
		mpf_class fac(1,FLOAT_PREC);
		for(int i = 0; i < n; i++) {
			MutInfCalculator temp_calc(e, i+1, tmp_edge);
			mpf_class temp_mut_inf = temp_calc.get_mut_inf();
			cout << e[0] << " " << e[1] << " " << temp_mut_inf << endl;
			tot_mut_inf += temp_mut_inf * fac;
			tmp_edge.push_back(pii(i,i+1));
			if(i != 0) {
				fac = fac * (N-i);
			}
		}
		cout << tot_mut_inf;
//		}
//	}
	
	return 0;

}
